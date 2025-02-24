# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module Annotation
      autoload :AnnotationBuilder, "annotaterb/model_annotator/annotation/annotation_builder"
      autoload :MainHeader, "annotaterb/model_annotator/annotation/main_header"
      autoload :SchemaHeader, "annotaterb/model_annotator/annotation/schema_header"
      autoload :MarkdownHeader, "annotaterb/model_annotator/annotation/markdown_header"
      autoload :SchemaFooter, "annotaterb/model_annotator/annotation/schema_footer"
    end
  end
end
