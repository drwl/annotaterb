# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class AnnotationPatternGenerator
      COMPAT_PREFIX = '== Schema Info'.freeze
      COMPAT_PREFIX_MD = '## Schema Info'.freeze

      class << self
        def call(options = Options.from({}))
          if options[:wrapper_open]
            return /(?:^(\n|\r\n)?# (?:#{options[:wrapper_open]}).*(\n|\r\n)?# (?:#{COMPAT_PREFIX}|#{COMPAT_PREFIX_MD}).*?(\n|\r\n)(#.*(\n|\r\n))*(\n|\r\n)*)|^(\n|\r\n)?# (?:#{COMPAT_PREFIX}|#{COMPAT_PREFIX_MD}).*?(\n|\r\n)(#.*(\n|\r\n))*(\n|\r\n)*/
          end
          /^(\n|\r\n)?# (?:#{COMPAT_PREFIX}|#{COMPAT_PREFIX_MD}).*?(\n|\r\n)(#.*(\n|\r\n))*(\n|\r\n)*/
        end
      end
    end
  end
end
