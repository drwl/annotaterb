# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ExclusionConstraintAnnotation
      autoload :AnnotationBuilder, "annotate_rb/model_annotator/exclusion_constraint_annotation/annotation_builder"
      autoload :Annotation, "annotate_rb/model_annotator/exclusion_constraint_annotation/annotation"
      autoload :ExclusionConstraintComponent, "annotate_rb/model_annotator/exclusion_constraint_annotation/exclusion_constraint_component"
    end
  end
end
