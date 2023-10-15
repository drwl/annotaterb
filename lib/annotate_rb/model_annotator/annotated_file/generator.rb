# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module AnnotatedFile
      # Generates the file with fresh annotations
      class Generator
        def initialize(file_components, annotation_position, options)
          @file_components = file_components
          @annotation_position = annotation_position
          @options = options

          @new_wrapped_annotations = wrapped_content(@file_components.new_annotations)
        end

        def generate
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
