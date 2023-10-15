# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module AnnotatedFile
      # Updates existing annotations
      class Updater
        def initialize(file_components, annotation_position, options)
          @file_components = file_components
          @annotation_position = annotation_position
          @options = options

          @new_wrapped_annotations = wrapped_content(@file_components.new_annotations)
        end

        def update
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
end
