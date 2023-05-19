# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Parses a model file into its relevant parts
    class AnnotatedFileParser
      SKIP_ANNOTATION_STRING = '# -*- SkipSchemaAnnotations'

      def initialize(file_content, new_annotations, options)
        @file_content = file_content
        @new_annotations = new_annotations
        @options = options
      end

      def parse
        @skip = @file_content.include?(SKIP_ANNOTATION_STRING)

        diff = AnnotationDiffGenerator.new(@file_content, @new_annotations).generate
        @annotations_changed = diff.changed?

        @new_wrapped_annotations = Helper.wrapped_content(@new_annotations, @options)

        @annotation_pattern = AnnotationPatternGenerator.call(@options)

        @old_annotations_v1 = @file_content.match(@annotation_pattern).to_s
      end

      def new_wrapped_annotations
        @new_wrapped_annotations
      end

      def annotation_pattern
        @annotation_pattern
      end

      # Taken from how FileAnnotator did it
      # Unclear how the regex patterns lead to different results than AnnotationDiffGenerator
      def old_annotations_v1
        @old_annotations_v1
      end

      def annotations_changed?
        @annotations_changed
      end

      def skip?
        @skip
      end
    end
  end
end