module AnnotateRb
  module ModelAnnotator
    module Constants
      TRUE_RE = /^(true|t|yes|y|1)$/i.freeze

      ##
      # The set of available options to customize the behavior of Annotate.
      #
      POSITION_OPTIONS = ::AnnotateRb::Options::POSITION_OPTION_KEYS

      FLAG_OPTIONS = ::AnnotateRb::Options::FLAG_OPTION_KEYS

      OTHER_OPTIONS = ::AnnotateRb::Options::OTHER_OPTION_KEYS

      PATH_OPTIONS = ::AnnotateRb::Options::PATH_OPTION_KEYS

      ALL_ANNOTATE_OPTIONS = ::AnnotateRb::Options::ALL_OPTION_KEYS
    end
  end
end
