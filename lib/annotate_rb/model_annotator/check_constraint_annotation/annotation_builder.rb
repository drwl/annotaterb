# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module CheckConstraintAnnotation
      class AnnotationBuilder
        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          constraint_info = if @options[:format_markdown]
            "#\n# ### Check Constraints\n#\n"
          else
            "#\n# Check Constraints\n#\n"
          end

          return "" unless @model.connection.respond_to?(:supports_check_constraints?) &&
            @model.connection.supports_check_constraints? && @model.connection.respond_to?(:check_constraints)

          check_constraints = @model.connection.check_constraints(@model.table_name)
          return "" if check_constraints.empty?

          max_size = check_constraints.map { |check_constraint| check_constraint.name.size }.max + 1
          check_constraints.sort_by(&:name).each do |check_constraint|
            expression = check_constraint.expression ? "(#{check_constraint.expression.squish})" : nil

            constraint_info += if @options[:format_markdown]
              cc_info_in_markdown(check_constraint.name, expression)
            else
              cc_info_string(check_constraint.name, expression, max_size)
            end
          end

          constraint_info
        end

        private

        def cc_info_in_markdown(name, expression)
          cc_info_markdown = sprintf("# * `%s`", name)
          cc_info_markdown += sprintf(": `%s`", expression) if expression
          cc_info_markdown += "\n"

          cc_info_markdown
        end

        def cc_info_string(name, expression, max_size)
          # standard:disable Lint/FormatParameterMismatch
          sprintf("#  %-#{max_size}.#{max_size}s %s", name, expression).rstrip + "\n"
          # standard:enable Lint/FormatParameterMismatch
        end
      end
    end
  end
end
