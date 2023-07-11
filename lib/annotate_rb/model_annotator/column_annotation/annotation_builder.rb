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
          result = ""

          is_primary_key = is_column_primary_key?(@model, @column.name)

          table_indices = @model.retrieve_indexes_from_table
          column_indices = table_indices.select { |ind| ind.columns.include?(@column.name) }
          column_defaults = @model.column_defaults

          column_attributes = AttributesBuilder.new(@column, @options, is_primary_key, column_indices, column_defaults).build
          formatted_column_type = TypeBuilder.new(@column, @options, column_defaults).build

          display_column_comments = @options[:with_comment] && @options[:with_column_comments]
          col_name = if display_column_comments && @model.with_comments? && @column.comment
            "#{@column.name}(#{@column.comment.gsub(/\n/, '\\n')})"
          else
            @column.name
          end

          result += if @options[:format_rdoc]
            format_rdoc(col_name, @max_size, formatted_column_type, column_attributes)
          elsif @options[:format_yard]
            format_yard(col_name, @max_size, formatted_column_type, column_attributes)
          elsif @options[:format_markdown]
            format_markdown(col_name, @max_size, formatted_column_type, column_attributes)
          else
            format_default(col_name, @max_size, formatted_column_type, column_attributes)
          end

          result
        end

        private

        def non_ascii_length(string)
          string.to_s.chars.count { |element| !element.ascii_only? }
        end

        def mb_chars_ljust(string, length)
          string = string.to_s
          padding = length - Helper.width(string)
          if padding.positive?
            string + (" " * padding)
          else
            string[0..(length - 1)]
          end
        end

        def map_col_type_to_ruby_classes(col_type)
          case col_type
          when "integer" then Integer.to_s
          when "float" then Float.to_s
          when "decimal" then BigDecimal.to_s
          when "datetime", "timestamp", "time" then Time.to_s
          when "date" then Date.to_s
          when "text", "string", "binary", "inet", "uuid" then String.to_s
          when "json", "jsonb" then Hash.to_s
          when "boolean" then "Boolean"
          end
        end

        def format_rdoc(col_name, max_size, formatted_column_type, column_attributes)
          format("# %-#{max_size}.#{max_size}s<tt>%s</tt>",
            "*#{col_name}*::",
            column_attributes.unshift(formatted_column_type).join(", ")).rstrip + "\n"
        end

        def format_yard(col_name, _max_size, formatted_column_type, _column_attributes)
          res = ""
          res += sprintf("# @!attribute #{col_name}") + "\n"

          ruby_class = if @column.respond_to?(:array) && @column.array
            "Array<#{map_col_type_to_ruby_classes(formatted_column_type)}>"
          else
            map_col_type_to_ruby_classes(formatted_column_type)
          end

          res += sprintf("#   @return [#{ruby_class}]") + "\n"

          res
        end

        def format_markdown(col_name, max_size, formatted_column_type, column_attributes)
          name_remainder = max_size - col_name.length - non_ascii_length(col_name)
          type_remainder = (MD_TYPE_ALLOWANCE - 2) - formatted_column_type.length

          format("# **`%s`**%#{name_remainder}s | `%s`%#{type_remainder}s | `%s`",
            col_name,
            " ",
            formatted_column_type,
            " ",
            column_attributes.join(", ").rstrip).gsub("``", "  ").rstrip + "\n"
        end

        def format_default(col_name, max_size, formatted_column_type, column_attributes)
          format("#  %s:%s %s",
            mb_chars_ljust(col_name, max_size),
            mb_chars_ljust(formatted_column_type, BARE_TYPE_ALLOWANCE),
            column_attributes.join(", ")).rstrip + "\n"
        end

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
