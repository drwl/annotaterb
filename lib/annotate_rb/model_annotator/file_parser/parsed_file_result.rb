# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      class ParsedFileResult
        def initialize(
          has_annotations:,
          has_skip_string:,
          annotations_changed:,
          annotations:,
          annotations_with_whitespace:
        )
          @has_annotations = has_annotations
          @has_skip_string = has_skip_string
          @annotations_changed = annotations_changed
          @annotations = annotations
          @annotations_with_whitespace = annotations_with_whitespace
        end

        attr_reader :annotations, :annotations_with_whitespace

        def annotations_changed?
          @annotations_changed
        end

        def has_annotations?
          @has_annotations
        end

        def has_skip_string?
          @has_skip_string
        end
      end
    end
  end
end
