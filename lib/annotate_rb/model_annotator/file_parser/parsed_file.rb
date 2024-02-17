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

        # standard:disable Lint/UnderscorePrefixedVariableName
        def parse
          @finder = AnnotationFinder.new(@file_content, @options[:wrapper_open], @options[:wrapper_close])
          _has_annotations = false

          begin
            @finder.run
            _has_annotations = @finder.annotated?
          rescue AnnotationFinder::NoAnnotationFound => _e
          end

          _annotations = @file_lines[(@finder.annotation_start)..(@finder.annotation_end)].join

          @diff = AnnotationDiffGenerator.new(_annotations, @new_annotations).generate
          @file_parser = @finder.parser

          _has_skip_string = @file_parser.comments.any? { |comment, _lineno| comment.include?(SKIP_ANNOTATION_STRING) }
          _annotations_changed = @diff.changed?
          _annotations_with_whitespace =
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

          @result = ParsedFileResult.new(
            has_annotations: _has_annotations,
            has_skip_string: _has_skip_string,
            annotations_changed: _annotations_changed,
            annotations: _annotations,
            annotations_with_whitespace: _annotations_with_whitespace
          )
        end
        # standard:enable Lint/UnderscorePrefixedVariableName

        def has_skip_string?
          @result.has_skip_string?
        end

        def annotations_changed?
          @result.annotations_changed?
        end

        def has_annotations?
          @result.has_annotations?
        end

        # Returns annotations with new line before and after if they exist
        def annotations_with_whitespace
          @result.annotations_with_whitespace
        end

        def annotations
          @result.annotations
        end
      end
    end
  end
end
