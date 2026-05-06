# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # A plain old Ruby object (PORO) that contains all necessary information for SingleFileAnnotator
    class SingleFileAnnotatorInstruction
      def initialize(file, annotation, position, options, model_class_name: nil)
        @file = file # Path to file
        @annotation = annotation # Annotation string
        @position = position # Position in the file where to write the annotation to
        @options = options
        @model_class_name = model_class_name # Short class name; set for the model file itself, nil for related files
      end

      attr_reader :file, :annotation, :position, :options, :model_class_name
    end
  end
end
