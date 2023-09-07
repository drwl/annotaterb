# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ColumnAnnotation
      class DefaultValueBuilder
        def initialize(value)
          @value = value
        end

        # @return [String]
        # Returns the value to get written to file by file.puts. Strings get written to file so escaped quoted strings
        # get written as quoted. For example, if `value: "\"some_string\""` then "some_string" gets written.
        # Same with arrays, if `value: "[\"a\", \"b\", \"c\"]"` then `["a", "b", "c"]` gets written.
        #
        # @example "\"some_string\""
        # @example "NULL"
        # @example "1.2"
        def build
          quote(@value)
        end

        private

        def quote(value)
          case value
          when NilClass then "NULL"
          when TrueClass then "TRUE"
          when FalseClass then "FALSE"
          when Float, Integer then value.to_s
          # BigDecimals need to be output in a non-normalized form and quoted.
          when BigDecimal then value.to_s("F")
          when Array then value.map { |v| quote(v) }
          else
            value.inspect
          end
        end
      end
    end
  end
end
