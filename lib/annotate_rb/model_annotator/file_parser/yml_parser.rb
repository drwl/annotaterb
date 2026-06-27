# frozen_string_literal: true

require "psych"

module AnnotateRb
  module ModelAnnotator
    module FileParser
      class YmlParser
        class << self
          def parse(string)
            _parser = new(string).tap(&:parse)
          end
        end

        attr_reader :comments, :starts, :ends

        def initialize(input)
          @input = input
          @comments = []
          @starts = []
          @ends = []
        end

        def parse
          parse_comments
          parse_yml
        end

        private

        def parse_comments
          # Adds 0-indexed line numbers
          @input.split($/).each_with_index do |line, line_no|
            if line.strip.starts_with?("#")
              @comments << [line, line_no]
            end
          end
        end

        def parse_yml
          # https://docs.ruby-lang.org/en/master/Psych.html#module-Psych-label-Reading+to+Psych-3A-3ANodes-3A-3AStream+structure
          parser = Psych.parser
          begin
            parser.parse(@input)
          rescue Psych::SyntaxError => _e
            # "Dynamic fixtures with ERB" exist in Rails and cause Psych.parser to error.
            #
            # We deliberately do not evaluate the ERB and read line numbers off the
            # result: evaluating runs arbitrary code, and the line numbers from the
            # evaluated output do not map back to the original file (ERB tags spanning
            # multiple lines shift the offsets), which would place annotations inside
            # an ERB tag. Instead we derive the content bounds straight from the
            # original lines so annotations land around the ERB body.
            return record_erb_positions
          end

          stream = parser.handler.root

          if stream.children.any?
            doc = stream.children.first
            @starts << [nil, doc.start_line]
            @ends << [nil, doc.end_line]
          else
            # When parsing a yml file, streamer returns an instance of `Psych::Nodes::Stream` which is a subclass of
            #   `Psych::Nodes::Node`. It along with children nodes, implement #start_line and #end_line.
            #
            # When parsing input that is only comments, the parser counts #start_line as the start of the file being
            #   line 0.
            #
            # What we really want is where the "start" of the yml file would happen, which would be after comments.
            # This is stream#end_line.
            @starts << [nil, stream.end_line]
            @ends << [nil, stream.end_line]
          end
        end

        # Locates the content bounds of an ERB fixture directly from the original
        # lines, treating the ERB/YAML body as the doc. The start is the first
        # non-blank, non-comment line so annotations are written above the ERB
        # block (and after any leading comments), never inside a tag.
        def record_erb_positions
          lines = @input.split($/)
          content_start = lines.index { |line| content_line?(line) }

          if content_start.nil?
            @starts << [nil, 0]
            @ends << [nil, 0]
          else
            content_end = lines.rindex { |line| content_line?(line) }
            @starts << [nil, content_start]
            @ends << [nil, content_end + 1]
          end
        end

        def content_line?(line)
          stripped = line.strip
          !stripped.empty? && !stripped.start_with?("#")
        end
      end
    end
  end
end
