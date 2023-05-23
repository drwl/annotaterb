# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Extracts magic comments strings and returns them
    class MagicCommentParser
      MAGIC_COMMENTS = [
        HASH_ENCODING = Regexp.new(/(^#\s*encoding:.*(?:\n|r\n))/),
        HASH_CODING = Regexp.new(/(^# coding:.*(?:\n|\r\n))/),
        HASH_FROZEN_STRING = Regexp.new(/(^#\s*frozen_string_literal:.+(?:\n|\r\n))/),
        STAR_ENCODING = Regexp.new(/(^# -\*- encoding\s?:.*(?:\n|\r\n))/),
        STAR_CODING = Regexp.new(/(^# -\*- coding:.*(?:\n|\r\n))/),
        STAR_FROZEN_STRING = Regexp.new(/(^# -\*- frozen_string_literal\s*:.+-\*-(?:\n|\r\n))/),
        SORBET_TYPED_STRING = Regexp.new(/(^#\s*typed:.*(?:\n|r\n))/).freeze
      ].freeze

      MAGIC_COMMENTS_REGEX = Regexp.union(*MAGIC_COMMENTS).freeze

      class << self
        def call(content)
          magic_comments = content.scan(MAGIC_COMMENTS_REGEX).flatten.compact

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
