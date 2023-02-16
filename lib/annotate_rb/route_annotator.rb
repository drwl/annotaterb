# frozen_string_literal: true

module AnnotateRb
  module RouteAnnotator
    autoload :Annotator, 'annotate_rb/route_annotator/annotator'
    autoload :Helper, 'annotate_rb/route_annotator/helper'
    autoload :HeaderGenerator, 'annotate_rb/route_annotator/header_generator'
  end
end
