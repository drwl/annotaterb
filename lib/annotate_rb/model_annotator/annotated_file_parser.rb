# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Parses a model file into its relevant parts
    class AnnotatedFileParser
      SKIP_ANNOTATION_STRING = '# -*- SkipSchemaAnnotations'

      def initialize(file_content, new_annotations, annotation_position, options)
        @file_content = file_content
        @new_annotations = new_annotations
        @annotation_position = annotation_position
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

      # Used when overwriting existing annotations OR model file has no annotations
      def regenerate_annotations
        magic_comments_block = Helper.magic_comments_as_string(@file_content)

        old_content = @file_content.gsub(Constants::MAGIC_COMMENT_MATCHER, '')
        old_content = old_content.sub(@annotation_pattern, '')

        # Need to keep `.to_s` for now since the it can be either a String or Symbol
        annotation_write_position = @options[@annotation_position].to_s

        if %w(after bottom).include?(annotation_write_position)
          new_content = magic_comments_block + (old_content.rstrip + "\n\n" + @new_wrapped_annotations)
        elsif magic_comments_block.empty?
          new_content = magic_comments_block + @new_wrapped_annotations + old_content.lstrip
        else
          new_content = magic_comments_block + "\n" + @new_wrapped_annotations + old_content.lstrip
        end

        new_content
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