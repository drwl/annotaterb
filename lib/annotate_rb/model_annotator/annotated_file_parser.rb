# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Parses a model file into its relevant parts
    class AnnotatedFileParser
      def initialize(file_content, new_annotations, annotation_position, options)
        @file_content = file_content
        @new_annotations = new_annotations
        @annotation_position = annotation_position
        @options = options
      end

      def parse
        @file_components = FileComponents.new(@file_content, @new_annotations, @options)

        @new_wrapped_annotations = wrapped_content(@new_annotations)

        @annotation_pattern = AnnotationPatternGenerator.call(@options)

        @regenerated_annotations = regenerate_annotations

        @updated_annotations = update_annotations
      end

      def regenerated_annotations
        @regenerated_annotations
      end

      def updated_annotations
        @updated_annotations
      end

      def new_wrapped_annotations
        @new_wrapped_annotations
      end

      def has_annotations?
        @file_components.has_annotations?
      end

      def annotations_changed?
        @file_components.annotations_changed?
      end

      def skip?
        @file_components.has_skip_string?
      end

      private

      # Used when overwriting existing annotations OR model file has no annotations
      def regenerate_annotations
        # Need to keep `.to_s` for now since the it can be either a String or Symbol
        annotation_write_position = @options[@annotation_position].to_s

        if %w(after bottom).include?(annotation_write_position)
          new_content = @file_components.magic_comments + (@file_components.pure_file_content.rstrip + "\n\n" + @new_wrapped_annotations)
        elsif @file_components.magic_comments.empty?
          new_content = @file_components.magic_comments + @new_wrapped_annotations + @file_components.pure_file_content.lstrip
        else
          new_content = @file_components.magic_comments + "\n" + @new_wrapped_annotations + @file_components.pure_file_content.lstrip
        end

        new_content
      end

      def update_annotations
        return '' if !@file_components.has_annotations?

        new_annotation = @file_components.space_before_annotation + @new_wrapped_annotations + @file_components.space_after_annotation

        new_content = @file_content.sub(@annotation_pattern, new_annotation)

        new_content
      end

      private

      def wrapped_content(content)
        if @options[:wrapper_open]
          wrapper_open = "# #{@options[:wrapper_open]}\n"
        else
          wrapper_open = ""
        end

        if @options[:wrapper_close]
          wrapper_close = "# #{@options[:wrapper_close]}\n"
        else
          wrapper_close = ""
        end

        _wrapped_info_block = "#{wrapper_open}#{content}#{wrapper_close}"
      end
    end
  end
end