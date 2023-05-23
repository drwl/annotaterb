# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Parses a model file into its relevant parts
    class AnnotatedFileParser
      class FileComponents
        def initialize(file_content, new_annotations, options)
          @file_content = file_content
          @diff = AnnotationDiffGenerator.new(file_content, new_annotations).generate
          @options = options
          @annotation_pattern = AnnotationPatternGenerator.call(options)
        end

        def skip?
          @skip ||= @file_content.include?(SKIP_ANNOTATION_STRING)
        end

        def has_annotations?
          @has_annotations ||= @diff.current_columns.present?
        end

        def annotations_changed?
          @has_annotations_changed ||= @diff.changed?
        end

        def current_annotations
          @current_annotations ||=
            begin
              if has_annotations?
                # `#has_annotations?` uses a different regex pattern than the one in `@annotation_pattern`,
                # this could lead to unexpected behavior
                @file_content.match(@annotation_pattern).to_s
              else
                ''
              end
            end
        end
      end

      SKIP_ANNOTATION_STRING = '# -*- SkipSchemaAnnotations'
      SOME_PATTERN = /\A(?<start>\s*).*?\n(?<end>\s*)\z/m # Unsure what this pattern is

      def initialize(file_content, new_annotations, annotation_position, options)
        @file_content = file_content
        @new_annotations = new_annotations
        @annotation_position = annotation_position
        @options = options
      end

      def parse
        @skip = @file_content.include?(SKIP_ANNOTATION_STRING)

        diff = AnnotationDiffGenerator.new(@file_content, @new_annotations).generate
        @annotations_changed = diff.changed?

        @new_wrapped_annotations = wrapped_content(@new_annotations)

        @annotation_pattern = AnnotationPatternGenerator.call(@options)

        @old_annotations_v1 = @file_content.match(@annotation_pattern).to_s

        @regenerated_annotations = regenerate_annotations

        @updated_annotations = update_annotations
      end

      def regenerated_annotations
        @regenerated_annotations
      end

      def updated_annotations
        @updated_annotations
      end

      def new_wrapped_annotations
        @new_wrapped_annotations
      end

      def annotation_pattern
        @annotation_pattern
      end

      # Taken from how FileAnnotator did it
      # Unclear how the regex patterns lead to different results than AnnotationDiffGenerator
      def old_annotations_v1
        @old_annotations_v1
      end

      def annotations_changed?
        @annotations_changed
      end

      def skip?
        @skip
      end

      private

      # Used when overwriting existing annotations OR model file has no annotations
      def regenerate_annotations
        # Method works as follows:
        # 1. Extract the magic comments in the file content into a variable to be used later
        # 2. Remove the magic comments in the file content
        # 3. Write annotations and generate the new file content that gets written to the file

        magic_comments_block = MagicCommentParser.call(@file_content)

        old_content = @file_content.gsub(MagicCommentParser::MAGIC_COMMENTS_REGEX, '')
        old_content = old_content.sub(@annotation_pattern, '')

        # Need to keep `.to_s` for now since the it can be either a String or Symbol
        annotation_write_position = @options[@annotation_position].to_s

        if %w(after bottom).include?(annotation_write_position)
          new_content = magic_comments_block + (old_content.rstrip + "\n\n" + @new_wrapped_annotations)
        elsif magic_comments_block.empty?
          new_content = magic_comments_block + @new_wrapped_annotations + old_content.lstrip
        else
          new_content = magic_comments_block + "\n" + @new_wrapped_annotations + old_content.lstrip
        end

        new_content
      end

      def update_annotations
        return '' if @old_annotations_v1.empty?

        space_match = @old_annotations_v1.match(SOME_PATTERN)
        new_annotation = space_match[:start] + @new_wrapped_annotations + space_match[:end]

        new_content = @file_content.sub(@annotation_pattern, new_annotation)

        new_content
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