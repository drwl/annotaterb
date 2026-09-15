# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ColumnAnnotation
      # Pairs the raw DB default of an enum backed column with its label, so
      # that annotations can show both.
      EnumDefault = Struct.new(:raw, :label)
    end
  end
end
