# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ColumnAnnotation
      class AnnotationBuilder
        def initialize(column, model, max_size, options)
          @column = column
          @model = model
          @max_size = max_size
          @options = options
        end

        def build
          is_primary_key = is_column_primary_key?(@model, @column.name)

          table_indices = @model.retrieve_indexes_from_table
          column_indices = table_indices.select { |ind| ind.columns.include?(@column.name) }
          column_defaults = @model.column_defaults

          column_attributes = AttributesBuilder.new(@column, @options, is_primary_key, column_indices, column_defaults).build
          formatted_column_type = TypeBuilder.new(@column, @options, column_defaults).build

          display_column_comments = @options[:with_comment] && @options[:with_column_comments]
          display_column_comments &&= @model.with_comments? && @column.comment
          position_of_column_comment = @options[:position_of_column_comment] || Options::FLAG_OPTIONS[:position_of_column_comment] if display_column_comments

          _component = ColumnComponent.new(
            column: @column,
            max_name_size: @max_size,
            type: formatted_column_type,
            attributes: column_attributes,
            position_of_column_comment:,
            max_attributes_size: @model.max_attributes_size
          )

        end

        private

        # TODO: Simplify this conditional
        def is_column_primary_key?(model, column_name)
          if model.primary_key
            if model.primary_key.is_a?(Array)
              # If the model has multiple primary keys, check if this column is one of them
              if model.primary_key.collect(&:to_sym).include?(column_name.to_sym)
                return true
              end
            elsif column_name.to_sym == model.primary_key.to_sym
              # If model has 1 primary key, check if this column is it
              return true
            end
          end

          false
        end
      end
    end
  end
end
