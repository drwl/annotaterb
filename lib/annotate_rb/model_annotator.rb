# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    autoload :Annotator, 'annotate_rb/model_annotator/annotator'
    autoload :Helper, 'annotate_rb/model_annotator/helper'
    autoload :FilePatterns, 'annotate_rb/model_annotator/file_patterns'
    autoload :Constants, 'annotate_rb/model_annotator/constants'
    autoload :SchemaInfo, 'annotate_rb/model_annotator/schema_info'
  end
end
