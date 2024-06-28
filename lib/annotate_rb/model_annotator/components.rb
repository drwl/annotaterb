# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Shared annotation components
    module Components
      class LineBreak
        def to_default
          ""
        end

        def to_markdown
          ""
        end
      end

      class BlankLine
        def to_default
          "#"
        end

        def to_markdown
          "#"
        end
      end

      Header = Struct.new(:header) do
        def to_default
          "# #{header}"
        end

        def to_markdown
          "# ### #{header}"
        end
      end
    end
  end
end
