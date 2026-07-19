# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ExclusionConstraintAnnotation
      class AnnotationBuilder
        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          return Components::NilComponent.new if !@options[:show_exclusion_constraints]
          return Components::NilComponent.new unless @model.connection.respond_to?(:supports_exclusion_constraints?) &&
            @model.connection.supports_exclusion_constraints? && @model.connection.respond_to?(:exclusion_constraints)

          exclusion_constraints = @model.connection.exclusion_constraints(@model.table_name)
          return Components::NilComponent.new if exclusion_constraints.empty?

          max_size = exclusion_constraints.map { |exclusion_constraint| exclusion_constraint.name.size }.max + 1

          constraints = exclusion_constraints.sort_by(&:name).map do |exclusion_constraint|
            details = "(#{exclusion_constraint.expression})"
            details += " USING #{exclusion_constraint.using}" if exclusion_constraint.using
            details += " WHERE (#{exclusion_constraint.where})" if exclusion_constraint.where
            if exclusion_constraint.deferrable
              details += " DEFERRABLE INITIALLY #{exclusion_constraint.deferrable.to_s.upcase}"
            end

            ExclusionConstraintComponent.new(exclusion_constraint.name, details, max_size)
          end

          _annotation = Annotation.new(constraints)
        end
      end
    end
  end
end
