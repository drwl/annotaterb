# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    module FileParser
      autoload :AnnotationFinder, "annotaterb/model_annotator/file_parser/annotation_finder"
      autoload :CustomParser, "annotaterb/model_annotator/file_parser/custom_parser"
      autoload :ParsedFile, "annotaterb/model_annotator/file_parser/parsed_file"
      autoload :ParsedFileResult, "annotaterb/model_annotator/file_parser/parsed_file_result"
      autoload :YmlParser, "annotaterb/model_annotator/file_parser/yml_parser"
    end
  end
end
