# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module CheckConstraintAnnotation
      class AnnotationBuilder
        CheckConstraint = Struct.new(:name, :expression, :max_size) do
          def to_default
            # standard:disable Lint/FormatParameterMismatch
            sprintf("#  %-#{max_size}.#{max_size}s %s", name, expression).rstrip
            # standard:enable Lint/FormatParameterMismatch
          end

          def to_markdown
            if expression
              sprintf("# * `%s`: `%s`", name, expression)
            else
              sprintf("# * `%s`", name)
            end
          end
        end

        class Annotation
          HEADER_TEXT = "Check Constraints"

          def initialize(constraints)
            @constraints = constraints
          end

          def body
            [
              Components::BlankLine.new,
              Components::Header.new(HEADER_TEXT),
              Components::BlankLine.new,
              *@constraints,
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
          return "" unless @model.connection.respond_to?(:supports_check_constraints?) &&
            @model.connection.supports_check_constraints? && @model.connection.respond_to?(:check_constraints)

          check_constraints = @model.connection.check_constraints(@model.table_name)
          return "" if check_constraints.empty?

          max_size = check_constraints.map { |check_constraint| check_constraint.name.size }.max + 1

          constraints = check_constraints.sort_by(&:name).map do |check_constraint|
            expression = if check_constraint.expression
              if check_constraint.validated?
                "(#{check_constraint.expression.squish})"
              else
                "(#{check_constraint.expression.squish}) NOT VALID".squish
              end
            end

            CheckConstraint.new(check_constraint.name, expression, max_size)
          end

          if @options[:format_markdown]
            Annotation.new(constraints).to_markdown
          else
            Annotation.new(constraints).to_default
          end
        end
      end
    end
  end
end
