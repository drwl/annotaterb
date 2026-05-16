# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      module MagicComment
        DIRECTIVE_KEYS = %w[
          encoding
          coding
          frozen_string_literal
          warn_indent
          shareable_constant_value
          typed
          rbs_inline
        ].freeze

        SIMPLE = /\A\s*#\s*(?<key>[A-Za-z][A-Za-z0-9_-]*)\s*:\s*\S/
        EMACS = /\A\s*#\s*-\*-.*-\*-\s*\z/
        VIM = /\A\s*#\s*vim:\s/

        def self.match?(line)
          if (m = SIMPLE.match(line))
            key = m[:key].downcase.tr("-", "_")
            return true if DIRECTIVE_KEYS.include?(key)
          end

          EMACS.match?(line) || VIM.match?(line)
        end
      end
    end
  end
end
