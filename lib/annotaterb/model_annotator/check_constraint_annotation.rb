# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module CheckConstraintAnnotation
      autoload :AnnotationBuilder, "annotaterb/model_annotator/check_constraint_annotation/annotation_builder"
      autoload :Annotation, "annotaterb/model_annotator/check_constraint_annotation/annotation"
      autoload :CheckConstraintComponent, "annotaterb/model_annotator/check_constraint_annotation/check_constraint_component"
    end
  end
end
