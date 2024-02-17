# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module AnnotatedFile
      # Updates existing annotations
      class Updater
        def initialize(file_components, _annotation_position, options)
          @options = options

          @new_annotations = file_components.new_annotations
          @file_content = file_components.current_file_content

          @parsed_file = FileParser::ParsedFile.new(@file_content, @new_annotations, options).parse
        end

        def update
          return "" if !@parsed_file.has_annotations?

          new_annotation = wrapped_content(@new_annotations)

          _content = @file_content.sub(@parsed_file.annotations, new_annotation)
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
end
