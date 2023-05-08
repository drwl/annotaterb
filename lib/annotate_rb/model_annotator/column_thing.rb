# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ColumnThing
      # Don't show default value for these column types
      NO_DEFAULT_COL_TYPES = %w[json jsonb hstore].freeze

      # Don't show limit (#) on these column types
      # Example: show "integer" instead of "integer(4)"
      NO_LIMIT_COL_TYPES = %w[integer bigint boolean].freeze

      def initialize(column, klass, options)
        @column = column
        @klass = klass
        @options = options
        @model_thing = ModelThing.new(@klass, @options)
      end

      # Get the list of attributes that should be included in the annotation for
      # a given column.
      def get_attributes(column_type)
        # Note: The input `column_type` gets modified in this method call.
        attrs = []

        # Note: Used to be klass.column_defaults[name], where name is the column name.
        # Looks to be identical, but keeping note here in case there are differences.
        column_default = @column.default

        unless default.nil? || hide_default?
          string_default_column_value = Helper.quote(column_default)
          schema_default = "default(#{string_default_column_value})"

          attrs << schema_default
        end

        if unsigned?
          attrs << 'unsigned'
        end

        if !null
          attrs << 'not null'
        end

        if model_primary_key
          if model_primary_key.is_a?(Array)
            if model_primary_key.collect(&:to_sym).include?(name.to_sym)
              attrs << 'primary key'
            end
          else
            if name.to_sym == model_primary_key.to_sym
              attrs << 'primary key'
            end
          end
        end

        if column_type == 'decimal'
          column_type << "(#{precision}, #{scale})"
        elsif !%w[spatial geometry geography].include?(column_type)
          if limit && !@options[:format_yard]
            if limit.is_a? Array
              attrs << "(#{limit.join(', ')})"
            else
              unless hide_limit?
                column_type << "(#{limit})"
              end
            end
          end
        end

        # Check out if we got an array column
        if array?
          attrs << 'is an Array'
        end

        # Check out if we got a geometric column
        # and print the type and SRID
        if geometry_type?
          attrs << "#{geometry_type}, #{srid}"
        elsif geometric_type? && geometric_type.present?
          attrs << "#{geometric_type.to_s.downcase}, #{srid}"
        end

        # Check if the column has indices and print "indexed" if true
        # If the index includes another column, print it too.
        if @options[:simple_indexes]
          sorted_column_indices&.each do |index|
            indexed_columns = index.columns.reject { |i| i == name }

            if indexed_columns.empty?
              attrs << 'indexed'
            else
              attrs << "indexed => [#{indexed_columns.join(', ')}]"
            end
          end
        end

        attrs
      end

      def sorted_column_indices
        table_indices = @model_thing.retrieve_indexes_from_table

        column_indices = table_indices.select { |ind| ind.columns.include? name }

        # Not sure why there were & safe accessors here, but keeping in for time being.
        sorted_indices = column_indices&.sort_by(&:name)

        _sorted_indices = sorted_indices.reject { |ind| ind.columns.is_a?(String) }
      end

      def model_primary_key
        @model_thing.primary_key
      end

      def default
        @column.default
      end

      def column_type
        Helper.get_col_type(@column)
      end

      def unsigned?
        @column.respond_to?(:unsigned?) && @column.unsigned?
      end

      def precision
        @column.precision
      end

      def scale
        @column.scale
      end

      def limit
        @column.limit
      end

      def name
        @column.name
      end

      def null
        @column.null
      end

      def geometry_type?
        @column.respond_to?(:geometry_type)
      end

      def geometry_type
        # TODO: Check if we need to check if it responds before accessing the geometry type
        @column.geometry_type
      end

      def geometric_type?
        @column.respond_to?(:geometric_type)
      end

      def geometric_type
        # TODO: Check if we need to check if it responds before accessing the geometric type
        @column.geometric_type
      end

      def srid
        # TODO: Check if we need to check if it responds before accessing the srid
        @column.srid
      end

      def array?
        @column.respond_to?(:array) && @column.array
      end

      def hide_limit?
        excludes =
          if @options[:hide_limit_column_types].blank?
            NO_LIMIT_COL_TYPES
          else
            @options[:hide_limit_column_types].split(',')
          end

        excludes.include?(column_type)
      end

      def hide_default?
        excludes =
          if @options[:hide_default_column_types].blank?
            NO_DEFAULT_COL_TYPES
          else
            @options[:hide_default_column_types].split(',')
          end

        excludes.include?(column_type)
      end
    end
  end
end