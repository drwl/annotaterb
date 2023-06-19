# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Generates the text file content with annotations, these are then to be written to filesystem.
    class FileBuilder
      def initialize(file_components, annotation_position, options)
        @file_components = file_components
        @annotation_position = annotation_position
        @options = options

        @new_wrapped_annotations = wrapped_content(@file_components.new_annotations)
      end

      def generate_content_with_new_annotations
        # Need to keep `.to_s` for now since the it can be either a String or Symbol
        annotation_write_position = @options[@annotation_position].to_s

        _content = if %w[after bottom].include?(annotation_write_position)
          @file_components.magic_comments + (@file_components.pure_file_content.rstrip + "\n\n" + @new_wrapped_annotations)
        elsif @file_components.magic_comments.empty?
          @file_components.magic_comments + @new_wrapped_annotations + @file_components.pure_file_content.lstrip
        else
          @file_components.magic_comments + "\n" + @new_wrapped_annotations + @file_components.pure_file_content.lstrip
        end
      end

      def update_existing_annotations
        return "" if !@file_components.has_annotations?

        annotation_pattern = AnnotationPatternGenerator.call(@options)

        new_annotation = @file_components.space_before_annotation + @new_wrapped_annotations + @file_components.space_after_annotation

        _content = @file_components.current_file_content.sub(annotation_pattern, new_annotation)
      end

      private

      def wrapped_content(content)
        wrapper_open = if @options[:wrapper_open]
          "# #{@options[:wrapper_open]}\n"
        else
          ""
        end

        wrapper_close = if @options[:wrapper_close]
          "# #{@options[:wrapper_close]}\n"
        else
          ""
        end

        _wrapped_info_block = "#{wrapper_open}#{content}#{wrapper_close}"
      end
    end
  end
end
