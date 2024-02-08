# frozen_string_literal: true

require "ripper"

module AnnotateRb
  module CommentParser
    class CommentParser < Ripper
      # Overview of Ripper: https://kddnewton.com/2022/02/14/formatting-ruby-part-1.html
      # Ripper API: https://kddnewton.com/ripper-docs/events

      class << self
        def parse(string)
          parser = new(string).tap { |p| p.parse }
          parser.comments
        end
      end

      attr_reader :comments

      def initialize(...)
        super
        @comments = []
      end

      def on_embdoc_beg(value)
        @comments << [value.strip, lineno]
      end

      def on_embdoc_end(value)
        @comments << [value.strip, lineno]
      end

      def on_embdoc(value)
        @comments << [value.strip, lineno]
      end

      def on_comment(value)
        @comments << [value.strip, lineno]
      end
    end
  end
end
