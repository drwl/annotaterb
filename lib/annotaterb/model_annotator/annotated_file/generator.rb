# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module AnnotatedFile
      # Generates the file with fresh annotations
      class Generator
        def initialize(file_content, new_annotations, annotation_position, parser_klass, parsed_file, options)
          @annotation_position = annotation_position
          @options = options

          @new_wrapped_annotations = wrapped_content(new_annotations)

          @new_annotations = new_annotations
          @file_content = file_content

          @parser = parser_klass
          @parsed_file = parsed_file
        end

        # @return [String] Returns the annotated file content to be written back to a file
        def generate
          # Need to keep `.to_s` for now since the it can be either a String or Symbol
          annotation_write_position = @options[@annotation_position].to_s

          # New method: first remove annotations
          content_without_annotations = if @parsed_file.has_annotations?
            @file_content.sub(@parsed_file.annotations_with_whitespace, "")
          elsif @options[:force]
            @file_content.sub(@parsed_file.annotations_with_whitespace, "")
          else
            @file_content
          end

          # We need to get class start and class end depending on the position
          parsed = @parser.parse(content_without_annotations)

          _content = if %w[after bottom].include?(annotation_write_position)
            content_annotated_after(parsed, content_without_annotations)
          else
            content_annotated_before(parsed, content_without_annotations, annotation_write_position)
          end
        end

        private

        def content_annotated_before(parsed, content_without_annotations, write_position)
          same_write_position = @parsed_file.has_annotations? && @parsed_file.annotation_position.to_s == write_position

          # Could error if there's no class or module declaration
          _constant_name, line_number_before = parsed.starts.first

          content_with_annotations_written_before = []
          content_with_annotations_written_before << content_without_annotations.lines[0...line_number_before]
          content_with_annotations_written_before << $/ if @parsed_file.has_leading_whitespace? && same_write_position
          content_with_annotations_written_before << @new_wrapped_annotations.lines
          content_with_annotations_written_before << $/ if @parsed_file.has_trailing_whitespace? && same_write_position
          content_with_annotations_written_before << content_without_annotations.lines[line_number_before..]

          content_with_annotations_written_before.join
        end

        def content_annotated_after(parsed, content_without_annotations)
          _constant_name, line_number_after = parsed.ends.last

          content_with_annotations_written_after = []
          content_with_annotations_written_after << content_without_annotations.lines[0..line_number_after]
          content_with_annotations_written_after << $/
          content_with_annotations_written_after << @new_wrapped_annotations.lines
          content_with_annotations_written_after << content_without_annotations.lines[(line_number_after + 1)..]

          content_with_annotations_written_after.join
        end

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
end
