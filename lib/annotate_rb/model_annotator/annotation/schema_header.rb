# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class SchemaHeader < Components::Base
        class TableName < Components::Base
          attr_reader :name

          def initialize(name)
            @name = name
          end

          def to_default
            "# Table name: #{name}"
          end

          def to_markdown
            "# Table name: `#{name}`"
          end
        end

        attr_reader :table_name, :table_comment

        def initialize(table_name, table_comment, options)
          @table_name = table_name
          @table_comment = table_comment
          @options = options
        end

        def body
          [
            Components::BlankCommentLine.new,
            TableName.new(name),
            Components::BlankCommentLine.new
          ]
        end

        def to_default
          body.map(&:to_default).join("\n")
        end

        def to_markdown
          body.map(&:to_markdown).join("\n")
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
