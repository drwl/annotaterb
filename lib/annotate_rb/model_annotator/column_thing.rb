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