# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    autoload :Annotator, 'annotate_rb/model_annotator/annotator'
    autoload :Constants, 'annotate_rb/model_annotator/constants'
    autoload :PatternGetter, 'annotate_rb/model_annotator/pattern_getter'
    autoload :BadModelFileError, 'annotate_rb/model_annotator/bad_model_file_error'
    autoload :FileNameResolver, 'annotate_rb/model_annotator/file_name_resolver'
    autoload :FileAnnotationRemover, 'annotate_rb/model_annotator/file_annotation_remover'
    autoload :AnnotationPatternGenerator, 'annotate_rb/model_annotator/annotation_pattern_generator'
    autoload :ModelClassGetter, 'annotate_rb/model_annotator/model_class_getter'
    autoload :ModelFilesGetter, 'annotate_rb/model_annotator/model_files_getter'
    autoload :FileAnnotator, 'annotate_rb/model_annotator/file_annotator'
    autoload :ModelFileAnnotator, 'annotate_rb/model_annotator/model_file_annotator'
    autoload :ModelWrapper, 'annotate_rb/model_annotator/model_wrapper'
    autoload :AnnotationGenerator, 'annotate_rb/model_annotator/annotation_generator'
    autoload :ColumnAnnotation, 'annotate_rb/model_annotator/column_annotation'
    autoload :IndexAnnotationBuilder, 'annotate_rb/model_annotator/index_annotation_builder'
    autoload :ForeignKeyAnnotationBuilder, 'annotate_rb/model_annotator/foreign_key_annotation_builder'
    autoload :RelatedFilesListBuilder, 'annotate_rb/model_annotator/related_files_list_builder'
    autoload :AnnotationDecider, 'annotate_rb/model_annotator/annotation_decider'
    autoload :FileAnnotatorInstruction, 'annotate_rb/model_annotator/file_annotator_instruction'
    autoload :AnnotationDiffGenerator, 'annotate_rb/model_annotator/annotation_diff_generator'
    autoload :AnnotationDiff, 'annotate_rb/model_annotator/annotation_diff'
    autoload :FileAnnotationGenerator, 'annotate_rb/model_annotator/file_annotation_generator'
    autoload :MagicCommentParser, 'annotate_rb/model_annotator/magic_comment_parser'
    autoload :FileComponents, 'annotate_rb/model_annotator/file_components'
  end
end
