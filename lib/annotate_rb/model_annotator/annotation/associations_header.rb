# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class AssociationsHeader < Components::Base
        def initialize
        end

        def to_default
          "#\n# Associations\n#"
        end

        def to_markdown
          "#\n# Associations\n#"
        end
      end
    end
  end
end
