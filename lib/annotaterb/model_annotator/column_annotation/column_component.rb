# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module ColumnAnnotation
      class ColumnComponent < Components::Base
        MD_TYPE_ALLOWANCE = 18
        BARE_TYPE_ALLOWANCE = 16

        attr_reader :name, :max_size, :type, :attributes

        def initialize(name, max_size, type, attributes)
          @name = name
          @max_size = max_size
          @type = type
          @attributes = attributes
        end

        def to_rdoc
          # standard:disable Lint/FormatParameterMismatch
          format("# %-#{max_size}.#{max_size}s<tt>%s</tt>",
            "*#{name}*::",
            attributes.unshift(type).join(", ")).rstrip
          # standard:enable Lint/FormatParameterMismatch
        end

        def to_yard
          res = ""
          res += sprintf("# @!attribute #{name}") + "\n"

          ruby_class = if @column.respond_to?(:array) && @column.array
            "Array<#{map_col_type_to_ruby_classes(type)}>"
          else
            map_col_type_to_ruby_classes(type)
          end

          res += sprintf("#   @return [#{ruby_class}]")

          res
        end

        def to_markdown
          name_remainder = max_size - name.length - non_ascii_length(name)
          type_remainder = (MD_TYPE_ALLOWANCE - 2) - type.length

          # standard:disable Lint/FormatParameterMismatch
          format("# **`%s`**%#{name_remainder}s | `%s`%#{type_remainder}s | `%s`",
            name,
            " ",
            type,
            " ",
            attributes.join(", ").rstrip).gsub("``", "  ").rstrip
          # standard:enable Lint/FormatParameterMismatch
        end

        def to_default
          format("#  %s:%s %s",
            mb_chars_ljust(name, max_size),
            mb_chars_ljust(type, BARE_TYPE_ALLOWANCE),
            attributes.join(", ")).rstrip
        end

        private

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

        def non_ascii_length(string)
          string.to_s.chars.count { |element| !element.ascii_only? }
        end
      end
    end
  end
end
