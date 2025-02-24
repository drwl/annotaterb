# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module ForeignKeyAnnotation
      autoload :AnnotationBuilder, "annotaterb/model_annotator/foreign_key_annotation/annotation_builder"
      autoload :Annotation, "annotaterb/model_annotator/foreign_key_annotation/annotation"
      autoload :ForeignKeyComponent, "annotaterb/model_annotator/foreign_key_annotation/foreign_key_component"
      autoload :ForeignKeyComponentBuilder, "annotaterb/model_annotator/foreign_key_annotation/foreign_key_component_builder"
    end
  end
end
