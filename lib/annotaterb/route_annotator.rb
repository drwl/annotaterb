# frozen_string_literal: true

module Annotaterb
  module RouteAnnotator
    autoload :Annotator, "annotaterb/route_annotator/annotator"
    autoload :Helper, "annotaterb/route_annotator/helper"
    autoload :HeaderGenerator, "annotaterb/route_annotator/header_generator"
    autoload :BaseProcessor, "annotaterb/route_annotator/base_processor"
    autoload :AnnotationProcessor, "annotaterb/route_annotator/annotation_processor"
    autoload :RemovalProcessor, "annotaterb/route_annotator/removal_processor"
  end
end
