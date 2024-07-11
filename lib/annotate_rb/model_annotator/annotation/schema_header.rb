# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class SchemaHeader < Components::Base
        attr_reader :table_name, :table_comment

        def initialize(table_name, table_comment, options)
          @table_name = table_name
          @table_comment = table_comment
          @options = options
        end

        def to_markdown
          <<~OUTPUT.strip
            #
            # Table name: `#{name}`
            #
          OUTPUT
        end

        def to_default
          <<~OUTPUT.strip
            #
            # Table name: #{name}
            #
          OUTPUT
        end

        private

        def display_table_comments?
          @options[:with_comment] && @options[:with_table_comments]
        end

        def name
          if display_table_comments? && table_comment
            formatted_comment = "(#{table_comment.gsub(/\n/, "\\n")})"

            "#{table_name}#{formatted_comment}"
          else
            table_name
          end
        end
      end
    end
  end
end
