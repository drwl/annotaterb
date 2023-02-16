# frozen_string_literal: true

module AnnotateRb
  module RouteAnnotator
    module Helper
      MAGIC_COMMENT_MATCHER = Regexp.new(/(^#\s*encoding:.*)|(^# coding:.*)|(^# -\*- coding:.*)|(^# -\*- encoding\s?:.*)|(^#\s*frozen_string_literal:.+)|(^# -\*- frozen_string_literal\s*:.+-\*-)/).freeze

      class << self
        def routes_file_exist?
          File.exist?(routes_file)
        end

        def routes_file
          @routes_rb ||= File.join('config', 'routes.rb')
        end

        def strip_on_removal(content, header_position)
          if header_position == :before
            content.shift while content.first == ''
          elsif header_position == :after
            content.pop while content.last == ''
          end

          # Make sure we end on a trailing newline.
          content << '' unless content.last == ''

          # TODO: If the user buried it in the middle, we should probably see about
          # TODO: preserving a single line of space between the content above and
          # TODO: below...
          content
        end

        def rewrite_contents(existing_text, new_text)
          if existing_text == new_text
            false
          else
            File.open(routes_file, 'wb') { |f| f.puts(new_text) }
            true
          end
        end

        # @param [Array<String>] content
        # @return [Array<String>] all found magic comments
        # @return [Array<String>] content without magic comments
        def extract_magic_comments_from_array(content_array)
          magic_comments = []
          new_content = []

          content_array.each do |row|
            if row =~ MAGIC_COMMENT_MATCHER
              magic_comments << row.strip
            else
              new_content << row
            end
          end

          [magic_comments, new_content]
        end
      end
    end
  end
end
