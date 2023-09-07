# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ColumnAnnotation
      class QuotedDefaultValueBuilder
        def initialize(value)
          @value = value
        end

        # @return [String]
        # Returns the value in escaped quoted String, to get written to file by file.puts.
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
