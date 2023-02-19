module AnnotateRb
  module ModelAnnotator
    module Constants
      TRUE_RE = /^(true|t|yes|y|1)$/i.freeze

      ##
      # The set of available options to customize the behavior of Annotate.
      #
      POSITION_OPTIONS = ::AnnotateRb::Options::POSITION_OPTIONS

      FLAG_OPTIONS = ::AnnotateRb::Options::FLAG_OPTIONS

      OTHER_OPTIONS = ::AnnotateRb::Options::OTHER_OPTIONS

      PATH_OPTIONS = ::AnnotateRb::Options::PATH_OPTIONS

      ALL_ANNOTATE_OPTIONS = ::AnnotateRb::Options::ALL_OPTIONS
    end
  end
end
