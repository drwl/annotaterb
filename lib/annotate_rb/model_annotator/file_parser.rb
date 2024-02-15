# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      autoload :MagicCommentParser, "annotate_rb/model_annotator/file_parser/magic_comment_parser"
      autoload :AnnotationFinder, "annotate_rb/model_annotator/file_parser/annotation_finder"
      autoload :CustomParser, "annotate_rb/model_annotator/file_parser/custom_parser"
      autoload :ParsedFile, "annotate_rb/model_annotator/file_parser/parsed_file"
    end
  end
end
