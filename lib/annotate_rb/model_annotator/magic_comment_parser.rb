# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Extracts magic comments strings and returns them
    class MagicCommentParser
      class << self
        def call(content)
          magic_comments = content.scan(Constants::MAGIC_COMMENT_MATCHER).flatten.compact

          if magic_comments.any?
            magic_comments.join
          else
            ''
          end
        end
      end
    end
  end
end