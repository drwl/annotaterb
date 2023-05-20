# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ColumnAnnotation
      class AnnotationBuilder
        BARE_TYPE_ALLOWANCE = 16
        MD_TYPE_ALLOWANCE = 18

        def initialize(column, model, max_size, options)
          @column = column
          @model = model
          @max_size = max_size
          @options = options
        end

        def build
          result = ''

          is_primary_key = is_column_primary_key?(@model, @column.name)

          table_indices = @model.retrieve_indexes_from_table
          column_indices = table_indices.select { |ind| ind.columns.include?(@column.name) }

          column_attributes = AttributesBuilder.new(@column, @options, is_primary_key, column_indices).build
          formatted_column_type = TypeBuilder.new(@column, @options).build

          col_name = if @model.with_comments? && @column.comment
                       "#{@column.name}(#{@column.comment.gsub(/\n/, '\\n')})"
                     else
                       @column.name
                     end

          if @options[:format_rdoc]
            result += format("# %-#{@max_size}.#{@max_size}s<tt>%s</tt>",
                             "*#{col_name}*::",
                             column_attributes.unshift(formatted_column_type).join(', ')).rstrip + "\n"
          elsif @options[:format_yard]
            result += sprintf("# @!attribute #{col_name}") + "\n"

            if @column.respond_to?(:array) && @column.array
              ruby_class = "Array<#{Helper.map_col_type_to_ruby_classes(formatted_column_type)}>"
            else
              ruby_class = Helper.map_col_type_to_ruby_classes(formatted_column_type)
            end

            result += sprintf("#   @return [#{ruby_class}]") + "\n"
          elsif @options[:format_markdown]
            name_remainder = @max_size - col_name.length - Helper.non_ascii_length(col_name)
            type_remainder = (MD_TYPE_ALLOWANCE - 2) - formatted_column_type.length
            result += format("# **`%s`**%#{name_remainder}s | `%s`%#{type_remainder}s | `%s`",
                             col_name,
                             ' ',
                             formatted_column_type,
                             ' ',
                             column_attributes.join(', ').rstrip).gsub('``', '  ').rstrip + "\n"
          else
            result += format_default(col_name, @max_size, formatted_column_type, column_attributes)
          end

          result
        end

        private

        def format_default(col_name, max_size, col_type, attrs)
          format('#  %s:%s %s',
                 Helper.mb_chars_ljust(col_name, max_size),
                 Helper.mb_chars_ljust(col_type, BARE_TYPE_ALLOWANCE),
                 attrs.join(', ')).rstrip + "\n"
        end

        # TODO: Simplify this conditional
        def is_column_primary_key?(model, column_name)
          if model.primary_key
            if model.primary_key.is_a?(Array)
              # If the model has multiple primary keys, check if this column is one of them
              if model.primary_key.collect(&:to_sym).include?(column_name.to_sym)
                return true
              end
            else
              # If model has 1 primary key, check if this column is it
              if column_name.to_sym == model.primary_key.to_sym
                return true
              end
            end
          end

          false
        end
      end
    end
  end
end
