# frozen_string_literal: true

module AnnotateRb
  module Helper
    # Unicode ranges that typically occupy 2 columns in monospace terminals.
    # This is a simplified wcwidth implementation.
    DOUBLE_WIDTH_RANGES = [
      0x1100..0x115F,   # Hangul Jamo
      0x2E80..0x303E,   # CJK Radicals, Kangxi, CJK Symbols
      0x3040..0x4DBF,   # Hiragana, Katakana, Bopomofo, CJK Ext A
      0x4E00..0x9FFF,   # CJK Unified Ideographs
      0xAC00..0xD7AF,   # Hangul Syllables
      0xF900..0xFAFF,   # CJK Compatibility Ideographs
      0xFE30..0xFE6F,   # CJK Compatibility Forms
      0xFF01..0xFF60,   # Fullwidth Forms
      0xFFE0..0xFFE6,   # Fullwidth Signs
      0x20000..0x2FA1F, # CJK Extensions B-F
      0x30000..0x3134F  # CJK Extensions G-I
    ].freeze

    class << self
      def width(string)
        string.each_char.sum { |char| double_width?(char) ? 2 : 1 }
      end

      # TODO: Find another implementation that doesn't depend on ActiveSupport
      def fallback(*args)
        args.compact.detect(&:present?)
      end

      private

      def double_width?(char)
        cp = char.ord
        DOUBLE_WIDTH_RANGES.any? { |range| range.cover?(cp) }
      end
    end
  end
end
