# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # TODO: Rename
    class FileAnnotationGenerator
      def initialize(file_components, new_annotations, annotation_position, options)
        @file_components = file_components
        @new_annotations = new_annotations
        @annotation_position = annotation_position
        @options = options

        @new_wrapped_annotations = wrapped_content(new_annotations)
      end

      def generate_content_with_new_annotations
        # Need to keep `.to_s` for now since the it can be either a String or Symbol
        annotation_write_position = @options[@annotation_position].to_s

        if %w(after bottom).include?(annotation_write_position)
          _content = @file_components.magic_comments + (@file_components.pure_file_content.rstrip + "\n\n" + @new_wrapped_annotations)
        elsif @file_components.magic_comments.empty?
          _content = @file_components.magic_comments + @new_wrapped_annotations + @file_components.pure_file_content.lstrip
        else
          _content = @file_components.magic_comments + "\n" + @new_wrapped_annotations + @file_components.pure_file_content.lstrip
        end
      end

      def update_existing_annotations
        return '' if !@file_components.has_annotations?

        annotation_pattern = AnnotationPatternGenerator.call(@options)

        new_annotation = @file_components.space_before_annotation + @new_wrapped_annotations + @file_components.space_after_annotation

        _content = @file_components.current_file_content.sub(annotation_pattern, new_annotation)
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