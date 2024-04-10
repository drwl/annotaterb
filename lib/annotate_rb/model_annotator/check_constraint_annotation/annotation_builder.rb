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

          klass = @model.instance_variable_get(:@klass)

          return "" unless klass.connection.respond_to?(:supports_check_constraints?) &&
            klass.connection.supports_check_constraints? && klass.connection.respond_to?(:check_constraints)

          check_constraints = klass.connection.check_constraints(klass.table_name)
          return "" if check_constraints.empty?

          max_size = check_constraints.map { |check_constraint| check_constraint.name.size }.max + 1
          check_constraints.sort_by(&:name).each do |check_constraint|
            expression = check_constraint.expression ? "(#{check_constraint.expression.squish})" : nil

            constraint_info += if @options[:format_markdown]
              cc_info_markdown = sprintf("# * `%s`", check_constraint.name)
              cc_info_markdown += sprintf(": `%s`", expression) if expression
              cc_info_markdown += "\n"

              cc_info_markdown
            else
              # standard:disable Lint/FormatParameterMismatch
              sprintf("#  %-#{max_size}.#{max_size}s %s", check_constraint.name, expression).rstrip + "\n"
              # standard:enable Lint/FormatParameterMismatch
            end
          end

          constraint_info
        end

        private
      end
    end
  end
end
