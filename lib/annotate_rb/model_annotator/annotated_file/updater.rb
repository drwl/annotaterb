# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module AnnotatedFile
      # Updates existing annotations
      class Updater
        def initialize(file_content, new_annotations, _annotation_position, parsed_file, options)
          @options = options

          @new_annotations = new_annotations
          @file_content = file_content

          @parsed_file = parsed_file
        end

        # @return [String] Returns the annotated file content to be written back to a file
        def update
          return "" if !@parsed_file.has_annotations?

          new_annotation = indent(wrapped_content(@new_annotations), existing_indentation)

          _content = @file_content.sub(@parsed_file.annotations) { new_annotation }
        end

        private

        # Returns the leading whitespace of the existing annotation block so
        # nested-position annotations keep their indentation across re-runs.
        def existing_indentation
          first_line = @parsed_file.annotations.lines.first
          first_line&.match(/\A([ \t]*)/)&.[](1) || ""
        end

        def indent(content, indentation)
          return content if indentation.empty?

          content.lines.map { |line| (line == "\n") ? line : "#{indentation}#{line}" }.join
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
