# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class MarkdownHeader < Components::Base
        MD_NAMES_OVERHEAD = 6
        MD_TYPE_ALLOWANCE = 18

        attr_reader :max_size

        def initialize(max_size)
          @max_size = max_size
        end

        def to_markdown
          info = "# ### Columns\n"
          info += "#\n"
          # standard:disable Lint/FormatParameterMismatch
          info += format("# %-#{max_size + MD_NAMES_OVERHEAD}.#{max_size + MD_NAMES_OVERHEAD}s | %-#{MD_TYPE_ALLOWANCE}.#{MD_TYPE_ALLOWANCE}s | %s\n",
            "Name",
            "Type",
            "Attributes")
          # standard:enable Lint/FormatParameterMismatch
          info += "# #{"-" * (max_size + MD_NAMES_OVERHEAD)} | #{"-" * MD_TYPE_ALLOWANCE} | #{"-" * 27}\n"

          info
        end

        def to_default
          nil
        end
      end
    end
  end
end
