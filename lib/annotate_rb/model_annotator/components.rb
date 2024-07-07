# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Shared annotation components
    module Components
      class Base
        # Methods default to #to_default, unless overridden by sub class
        def to_markdown
          to_default
        end

        def to_rdoc
          to_default
        end

        def to_yard
          to_default
        end

        def to_default
          raise NoMethodError, "Not implemented by class #{self.class}"
        end
      end

      class LineBreak < Base
        def to_default
          ""
        end
      end

      class BlankLine < Base
        def to_default
          "#"
        end
      end

      class Header < Base
        attr_reader :header

        def initialize(header)
          @header = header
        end

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
