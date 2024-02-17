# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      class ParsedFile
        SKIP_ANNOTATION_STRING = "# -*- SkipSchemaAnnotations"

        def initialize(file_content, new_annotations, options)
          @file_content = file_content
          @file_lines = @file_content.lines
          @new_annotations = new_annotations
          @options = options
        end

        def parse
          @finder = AnnotationFinder.new(@file_content, @options[:wrapper_open], @options[:wrapper_close])
          @finder.run

          @diff = AnnotationDiffGenerator.new(annotations, @new_annotations).generate
          @file_parser = @finder.parser
        end

        def has_skip_string?
          @has_skip_string ||= @file_parser.comments.any? { |comment, _lineno| comment.include?(SKIP_ANNOTATION_STRING) }
        end

        def annotations_changed?
          @annotations_changed ||= @diff.changed?
        end

        def has_annotations?
          @finder.annotated?
        end

        # Returns annotations with new line before and after if they exist
        def annotations_with_whitespace
          @annotations_trailing_line ||=
            begin
              annotation_start = @finder.annotation_start
              annotation_end = @finder.annotation_end

              if @file_lines[annotation_start - 1]&.strip&.empty?
                annotation_start -= 1
              end

              if @file_lines[annotation_end + 1]&.strip&.empty?
                annotation_end += 1
              end

              @file_lines[annotation_start..annotation_end].join
            end
        end

        def annotations
          @annotations ||= @file_lines[(@finder.annotation_start)..(@finder.annotation_end)].join
        end
      end
    end
  end
end
