# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ColumnThing
      # Don't show default value for these column types
      NO_DEFAULT_COL_TYPES = %w[json jsonb hstore].freeze

      # Don't show limit (#) on these column types
      # Example: show "integer" instead of "integer(4)"
      NO_LIMIT_COL_TYPES = %w[integer bigint boolean].freeze

      def initialize(column, options)
        @column = column
        @options = options
      end

      # Get the list of attributes that should be included in the annotation for
      # a given column.
      def get_attributes(column_type, klass)
        # Note: The input `column_type` gets modified in this method call.
        attrs = []

        model_thing = ModelThing.new(klass, @options)

        unless default.nil? || hide_default?
          attrs << "default(#{schema_default(klass)})"
        end

        if unsigned?
          attrs << 'unsigned'
        end

        if !null
          attrs << 'not null'
        end

        if klass.primary_key
          if klass.primary_key.is_a?(Array)
            if klass.primary_key.collect(&:to_sym).include?(name.to_sym)
              attrs << 'primary key'
            end
          else
            if name.to_sym == klass.primary_key.to_sym
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
        if @options[:simple_indexes] && klass.table_exists? # Check out if this column is indexed
          table_indices = model_thing.retrieve_indexes_from_table
          indices = table_indices.select { |ind| ind.columns.include? name }
          indices&.sort_by(&:name)&.each do |ind|
            next if ind.columns.is_a?(String)

            ind = ind.columns.reject! { |i| i == name }
            attrs << (ind.empty? ? 'indexed' : "indexed => [#{ind.join(', ')}]")
          end
        end

        attrs
      end

      def schema_default(klass)
        Helper.quote(klass.column_defaults[name])
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