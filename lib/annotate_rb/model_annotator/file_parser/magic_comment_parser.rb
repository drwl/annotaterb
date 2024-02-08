# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      # Extracts magic comments strings and returns them
      class MagicCommentParser
        MAGIC_COMMENTS = [
          HASH_ENCODING = /(^#\s*encoding:.*(?:\n|r\n))/,
          HASH_CODING = /(^# coding:.*(?:\n|\r\n))/,
          HASH_FROZEN_STRING = /(^#\s*frozen_string_literal:.+(?:\n|\r\n))/,
          STAR_ENCODING = /(^# -\*- encoding\s?:.*(?:\n|\r\n))/,
          STAR_CODING = /(^# -\*- coding:.*(?:\n|\r\n))/,
          STAR_FROZEN_STRING = /(^# -\*- frozen_string_literal\s*:.+-\*-(?:\n|\r\n))/,
          SORBET_TYPED_STRING = /(^#\s*typed:.*(?:\n|r\n))/.freeze
        ].freeze

        MAGIC_COMMENTS_REGEX = Regexp.union(*MAGIC_COMMENTS).freeze

        class << self
          def call(content)
            parsed_comments = CommentParser::CommentParser.parse(content)
            comments = parsed_comments.map { |comment, _line_number| "#{comment}\n" }.join

            magic_comments = comments.scan(MAGIC_COMMENTS_REGEX).flatten.compact

            if magic_comments.any?
              magic_comments.join
            else
              ""
            end
          end
        end
      end
    end
  end
end
