# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ColumnAnnotationBuilder
      # Don't show default value for these column types
      NO_DEFAULT_COL_TYPES = %w[json jsonb hstore].freeze

      # Don't show limit (#) on these column types
      # Example: show "integer" instead of "integer(4)"
      NO_LIMIT_COL_TYPES = %w[integer bigint boolean].freeze

      def initialize(column, options, is_primary_key, column_indices)
        @column = ColumnWrapper.new(column)
        @options = options
        @is_primary_key = is_primary_key
        @column_indices = column_indices
      end

      # Get the list of attributes that should be included in the annotation for
      # a given column.
      def build
        column_type = @column.column_type_string
        attrs = []

        unless @column.default.nil? || hide_default?
          schema_default = "default(#{@column.default_string})"

          attrs << schema_default
        end

        if @column.unsigned?
          attrs << 'unsigned'
        end

        if !@column.null
          attrs << 'not null'
        end

        if @is_primary_key
          attrs << 'primary key'
        end

        formatted_column_type = column_type

        if column_type == 'decimal'
          formatted_column_type = "decimal(#{@column.precision}, #{@column.scale})"
        elsif !%w[spatial geometry geography].include?(column_type)
          if @column.limit && !@options[:format_yard]
            if @column.limit.is_a?(Array)
              attrs << "(#{@column.limit.join(', ')})"
            else
              unless hide_limit?
                formatted_column_type = column_type + "(#{@column.limit})"
              end
            end
          end
        end

        # Check out if we got an array column
        if @column.array?
          attrs << 'is an Array'
        end

        # Check out if we got a geometric column
        # and print the type and SRID
        if @column.geometry_type?
          attrs << "#{@column.geometry_type}, #{@column.srid}"
        elsif @column.geometric_type? && @column.geometric_type.present?
          attrs << "#{@column.geometric_type.to_s.downcase}, #{@column.srid}"
        end

        # Check if the column has indices and print "indexed" if true
        # If the index includes another column, print it too.
        if @options[:simple_indexes]
          # Note: there used to be a klass.table_exists? call here, but removed it as it seemed unnecessary.

          sorted_column_indices&.each do |index|
            indexed_columns = index.columns.reject { |i| i == @column.name }

            if indexed_columns.empty?
              attrs << 'indexed'
            else
              attrs << "indexed => [#{indexed_columns.join(', ')}]"
            end
          end
        end

        {
          attributes: attrs,
          column_type: formatted_column_type
        }
      end

      def sorted_column_indices
        # Not sure why there were & safe accessors here, but keeping in for time being.
        sorted_indices = @column_indices&.sort_by(&:name)

        _sorted_indices = sorted_indices.reject { |ind| ind.columns.is_a?(String) }
      end

      def hide_limit?
        excludes =
          if @options[:hide_limit_column_types].blank?
            NO_LIMIT_COL_TYPES
          else
            @options[:hide_limit_column_types].split(',')
          end

        excludes.include?(@column.column_type_string)
      end

      def hide_default?
        excludes =
          if @options[:hide_default_column_types].blank?
            NO_DEFAULT_COL_TYPES
          else
            @options[:hide_default_column_types].split(',')
          end

        excludes.include?(@column.column_type_string)
      end
    end
  end
end