# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ForeignKeyAnnotation
      class AnnotationBuilder
        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          return "" unless @model.connection.respond_to?(:supports_foreign_keys?) &&
            @model.connection.supports_foreign_keys? && @model.connection.respond_to?(:foreign_keys)

          foreign_keys = @model.connection.foreign_keys(@model.table_name)
          return "" if foreign_keys.empty?

          fks = foreign_keys.map do |fk|
            ForeignKeyComponentBuilder.new(fk, @options)
          end

          max_size = fks.map(&:formatted_name).map(&:size).max + 1

          foreign_key_components = fks.sort_by { |fk| [fk.formatted_name, fk.stringified_columns] }.map do |fk|
            # fk is a ForeignKeyComponentBuilder

            ForeignKeyComponent.new(fk.formatted_name, fk.constraints_info, fk.ref_info, max_size)
          end

          if @options[:format_markdown]
            Annotation.new(foreign_key_components).to_markdown
          else
            Annotation.new(foreign_key_components).to_default
          end
        end
      end
    end
  end
end
