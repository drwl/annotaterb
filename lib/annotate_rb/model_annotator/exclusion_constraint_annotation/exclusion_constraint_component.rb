# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ExclusionConstraintAnnotation
      class ExclusionConstraintComponent < Components::Base
        attr_reader :name, :details, :max_size

        def initialize(name, details, max_size)
          @name = name
          @details = details
          @max_size = max_size
        end

        def to_default
          # standard:disable Lint/FormatParameterMismatch
          sprintf("#  %-#{max_size}.#{max_size}s %s", name, details).rstrip
          # standard:enable Lint/FormatParameterMismatch
        end

        def to_markdown
          sprintf("# * `%s`: `%s`", name, details)
        end
      end
    end
  end
end
