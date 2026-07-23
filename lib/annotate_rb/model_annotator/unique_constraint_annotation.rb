# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module UniqueConstraintAnnotation
      autoload :AnnotationBuilder, "annotate_rb/model_annotator/unique_constraint_annotation/annotation_builder"
      autoload :Annotation, "annotate_rb/model_annotator/unique_constraint_annotation/annotation"
      autoload :UniqueConstraintComponent, "annotate_rb/model_annotator/unique_constraint_annotation/unique_constraint_component"
    end
  end
end
