# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module IndexAnnotation
      class AnnotationBuilder
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
