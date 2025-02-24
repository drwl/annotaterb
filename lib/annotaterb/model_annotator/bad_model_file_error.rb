# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    class BadModelFileError < LoadError
      def to_s
        "file doesn't contain a valid model class"
      end
    end
  end
end
