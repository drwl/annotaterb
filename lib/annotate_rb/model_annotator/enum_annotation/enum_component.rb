# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module EnumAnnotation
      class EnumComponent < Components::Base
        attr_reader :name, :values, :max_size

        def initialize(name, values, max_size)
          @name = name
          @values = values
          @max_size = max_size
        end

        def to_default
          # standard:disable Lint/FormatParameterMismatch
          sprintf("#  %-#{max_size}.#{max_size}s %s", name, values.join(", ")).rstrip
          # standard:enable Lint/FormatParameterMismatch
        end

        def to_markdown
          sprintf("# * `%s`: `%s`", name, values.join(", "))
        end
      end
    end
  end
end
