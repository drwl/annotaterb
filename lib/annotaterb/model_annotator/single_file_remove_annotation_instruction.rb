# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    # A plain old Ruby object (PORO) that contains all necessary information for SingleFileAnnotationRemover
    class SingleFileRemoveAnnotationInstruction
      def initialize(file, options)
        @file = file # Path to file
        @options = options
      end

      attr_reader :file, :options
    end
  end
end
