# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      class AnnotationFinder
        COMPAT_PREFIX = "== Schema Info"
        COMPAT_PREFIX_MD = "## Schema Info"
        DEFAULT_ANNOTATION_ENDING = "#"

        SCHEMA_HEADER_PREFIXES = [
          COMPAT_PREFIX,
          COMPAT_PREFIX_MD,
          "Table name:",
          "Database name:",
          "Schema version:"
        ].freeze

        SCHEMA_HEADER_EXACT = [
          IndexAnnotation::Annotation::HEADER_TEXT,
          ForeignKeyAnnotation::Annotation::HEADER_TEXT,
          CheckConstraintAnnotation::Annotation::HEADER_TEXT,
          UniqueConstraintAnnotation::Annotation::HEADER_TEXT,
          ExclusionConstraintAnnotation::Annotation::HEADER_TEXT,
          EnumAnnotation::Annotation::HEADER_TEXT
        ].freeze

        # `format_markdown: true` renders each of the section headers above as
        # "### <name>" instead of "<name>", so SCHEMA_HEADER_EXACT can't match it directly.
        # There's no HEADER_TEXT constant for the columns table itself,
        # so "Columns" is listed explicitly here.
        MARKDOWN_HEADER_PREFIX = "### "
        MARKDOWN_SECTION_HEADERS = (SCHEMA_HEADER_EXACT + ["Columns"]).freeze

        class MalformedAnnotation < StandardError; end

        class NoAnnotationFound < StandardError; end

        # Returns the line index (not the line number) that the annotation starts.
        attr_reader :annotation_start
        # Returns the line index (not the line number) that the annotation ends, inclusive.
        attr_reader :annotation_end

        attr_reader :parser

        def initialize(content, wrapper_open, wrapper_close, parser)
          @content = content
          @wrapper_open = wrapper_open
          @wrapper_close = wrapper_close
          @annotation_start = nil
          @annotation_end = nil
          @parser = parser
        end

        # Find the annotation's line start and line end
        def run
          comments = @parser.comments

          start = comments.find_index { |comment, _| comment.include?(COMPAT_PREFIX) || comment.include?(COMPAT_PREFIX_MD) }
          raise NoAnnotationFound if start.nil? # Stop execution because we did not find

          if @wrapper_open
            prev_comment, _prev_line_number = comments[start - 1]

            # Change start to the line before if wrapper_open is defined and we find the wrapper open comment
            if prev_comment&.include?(@wrapper_open)
              start -= 1
            end
          end

          # Find a contiguous block of comments from the starting point
          ending = start
          while ending < comments.size - 1
            _comment, line_number = comments[ending]
            _next_comment, next_line_number = comments[ending + 1]

            if next_line_number - line_number == 1
              ending += 1
            else
              break
            end
          end

          raise MalformedAnnotation if start == ending

          if @wrapper_close
            if comments[ending].first.include?(@wrapper_close)
              # We can end here because it's the end of the annotation block
            else
              # Walk back until we find the end of the annotation comment block or the wrapper close to be flexible
              #  We check if @wrapper_close is a substring because `comments` contains strings with the comment character
              while ending > start && comments[ending].first != DEFAULT_ANNOTATION_ENDING && !comments[ending].first.include?(@wrapper_close)
                ending -= 1
              end
            end
          else
            ending = walk_forward_through_schema(comments, start, ending)
          end

          # We want .last because we want the line indexes
          @annotation_start = comments[start].last
          @annotation_end = comments[ending].last

          [@annotation_start, @annotation_end]
        end

        def annotation
          @annotation ||=
            begin
              lines = @content.lines
              lines[@annotation_start..@annotation_end].join
            end
        end

        # Returns true if annotations are detected in the file content
        def annotated?
          @annotation_start && @annotation_end
        end

        private

        def walk_forward_through_schema(comments, start, block_end)
          ending = start
          while ending < block_end
            break unless schema_like?(comments[ending + 1].first)
            ending += 1
          end
          ending
        end

        # A line is part of the schema block if it matches one of the known
        # header prefixes/exact texts, or if it looks like a tabular/list row
        # of the annotation body:
        #
        # - Default/plain format: rows have >= 2 leading spaces after `#`
        #   (e.g. "#  id  :integer  not null"); prose has at most one.
        # - Markdown format (`format_markdown: true`) instead uses a single
        #   leading space after `#` for everything, so it needs its own
        #   detection: "### <name>" section headers (matched against
        #   MARKDOWN_SECTION_HEADERS with the prefix stripped), "|"-delimited
        #   table rows (header/divider/data), and "* `...`" bulleted list
        #   items for indexes/foreign keys/enums.
        def schema_like?(comment)
          return true if comment == DEFAULT_ANNOTATION_ENDING

          text = comment.sub(/\A#\s?/, "")
          return false if text.empty?

          return true if SCHEMA_HEADER_PREFIXES.any? { |p| text.start_with?(p) }
          return true if SCHEMA_HEADER_EXACT.include?(text)

          # Markdown section headers, e.g. "### Columns", "### Indexes".
          if text.start_with?(MARKDOWN_HEADER_PREFIX)
            return MARKDOWN_SECTION_HEADERS.include?(text.delete_prefix(MARKDOWN_HEADER_PREFIX))
          end

          # Requires at least two | separators to identify Markdown tables.
          # This prevents normal user comments containing a single | from being mistaken for a table.
          return true if text.count("|") >= 2

          # Markdown bulleted list items used for foreign keys/indexes/enums,
          # e.g. "* `index_name`:" or the nested "    * **`column`**". The
          # backtick right after the bullet marker distinguishes these from
          # an unrelated user comment that starts with a plain "* ".
          return true if text.match?(/\A\s*\*\s+\*{0,2}`/)

          comment.match?(/\A#\s{2,}\S/)
        end
      end
    end
  end
end
