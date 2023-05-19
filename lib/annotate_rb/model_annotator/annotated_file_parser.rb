# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Parses a model file into its relevant parts
    class AnnotatedFileParser
      SKIP_ANNOTATION_STRING = '# -*- SkipSchemaAnnotations'

      def initialize(file_content, options)
        @file_content = file_content
        @options = options
      end

      def parse
        # Check to skip
        @skip = @file_content.include?(SKIP_ANNOTATION_STRING)

      end

      def skip?
        @skip
      end
    end
  end
end