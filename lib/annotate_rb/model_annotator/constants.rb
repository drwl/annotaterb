module AnnotateRb
  module ModelAnnotator
    module Constants
      ##
      # The set of available options to customize the behavior of Annotate.
      #
      POSITION_OPTIONS = ::AnnotateRb::Options::POSITION_OPTION_KEYS

      FLAG_OPTIONS = ::AnnotateRb::Options::FLAG_OPTION_KEYS

      OTHER_OPTIONS = ::AnnotateRb::Options::OTHER_OPTION_KEYS

      PATH_OPTIONS = ::AnnotateRb::Options::PATH_OPTION_KEYS

      ALL_ANNOTATE_OPTIONS = ::AnnotateRb::Options::ALL_OPTION_KEYS

      SKIP_ANNOTATION_PREFIX = '# -\*- SkipSchemaAnnotations'.freeze

      MAGIC_COMMENT_MATCHER = Regexp.new(/(^#\s*encoding:.*(?:\n|r\n))|(^# coding:.*(?:\n|\r\n))|(^# -\*- coding:.*(?:\n|\r\n))|(^# -\*- encoding\s?:.*(?:\n|\r\n))|(^#\s*frozen_string_literal:.+(?:\n|\r\n))|(^# -\*- frozen_string_literal\s*:.+-\*-(?:\n|\r\n))/).freeze
    end
  end
end
