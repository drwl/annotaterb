# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module ColumnAnnotation
      autoload :AttributesBuilder, "annotaterb/model_annotator/column_annotation/attributes_builder"
      autoload :TypeBuilder, "annotaterb/model_annotator/column_annotation/type_builder"
      autoload :ColumnWrapper, "annotaterb/model_annotator/column_annotation/column_wrapper"
      autoload :AnnotationBuilder, "annotaterb/model_annotator/column_annotation/annotation_builder"
      autoload :DefaultValueBuilder, "annotaterb/model_annotator/column_annotation/default_value_builder"
      autoload :ColumnComponent, "annotaterb/model_annotator/column_annotation/column_component"
    end
  end
end
