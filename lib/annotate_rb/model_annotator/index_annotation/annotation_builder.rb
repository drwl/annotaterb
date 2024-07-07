# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module IndexAnnotation
      class AnnotationBuilder
        class Annotation
          HEADER_TEXT = "Indexes"

          def initialize(indexes)
            @indexes = indexes
          end

          def body
            [
              Components::BlankLine.new,
              Components::Header.new(HEADER_TEXT),
              Components::BlankLine.new,
              *@indexes,
              Components::LineBreak.new
            ]
          end

          def to_markdown
            body.map(&:to_markdown).join("\n")
          end

          def to_default
            body.map(&:to_default).join("\n")
          end
        end

        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          indexes = @model.retrieve_indexes_from_table
          return "" if indexes.empty?

          max_size = indexes.map { |index| index.name.size }.max + 1

          indexes = indexes.sort_by(&:name).map do |index|
            IndexComponent.new(index, max_size)
          end

          if @options[:format_markdown]
            Annotation.new(indexes).to_markdown
          else
            Annotation.new(indexes).to_default
          end
        end
      end
    end
  end
end
