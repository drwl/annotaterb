# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module EnumAnnotation
      autoload :AnnotationBuilder, "annotate_rb/model_annotator/enum_annotation/annotation_builder"
      autoload :Annotation, "annotate_rb/model_annotator/enum_annotation/annotation"
      autoload :EnumComponent, "annotate_rb/model_annotator/enum_annotation/enum_component"
    end
  end
end
