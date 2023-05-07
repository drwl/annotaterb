# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ColumnThing
      # Don't show default value for these column types
      NO_DEFAULT_COL_TYPES = %w[json jsonb hstore].freeze

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