# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module UniqueConstraintAnnotation
      class AnnotationBuilder
        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          return Components::NilComponent.new if !@options[:show_unique_constraints]
          return Components::NilComponent.new unless @model.connection.respond_to?(:supports_unique_constraints?) &&
            @model.connection.supports_unique_constraints? && @model.connection.respond_to?(:unique_constraints)

          unique_constraints = @model.connection.unique_constraints(@model.table_name)
          return Components::NilComponent.new if unique_constraints.empty?

          max_size = unique_constraints.map { |unique_constraint| unique_constraint.name.size }.max + 1

          constraints = unique_constraints.sort_by(&:name).map do |unique_constraint|
            columns = Array(unique_constraint.column)
            details = "(#{columns.join(", ")})"
            if unique_constraint.deferrable
              details += " DEFERRABLE INITIALLY #{unique_constraint.deferrable.to_s.upcase}"
            end

            UniqueConstraintComponent.new(unique_constraint.name, details, max_size)
          end

          _annotation = Annotation.new(constraints)
        end
      end
    end
  end
end
