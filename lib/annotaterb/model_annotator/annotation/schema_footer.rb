# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module Annotation
      class SchemaFooter < Components::Base
        def to_rdoc
          <<~OUTPUT
            #--
            # == Schema Information End
            #++
          OUTPUT
        end

        def to_default
          <<~OUTPUT
            #
          OUTPUT
        end
      end
    end
  end
end
