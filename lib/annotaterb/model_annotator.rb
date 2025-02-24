# frozen_string_literal: true

module Annotaterb
  module ModelAnnotator
    autoload :Annotator, "annotaterb/model_annotator/annotator"
    autoload :PatternGetter, "annotaterb/model_annotator/pattern_getter"
    autoload :BadModelFileError, "annotaterb/model_annotator/bad_model_file_error"
    autoload :FileNameResolver, "annotaterb/model_annotator/file_name_resolver"
    autoload :SingleFileAnnotationRemover, "annotaterb/model_annotator/single_file_annotation_remover"
    autoload :ModelClassGetter, "annotaterb/model_annotator/model_class_getter"
    autoload :ModelFilesGetter, "annotaterb/model_annotator/model_files_getter"
    autoload :SingleFileAnnotator, "annotaterb/model_annotator/single_file_annotator"
    autoload :ModelWrapper, "annotaterb/model_annotator/model_wrapper"
    autoload :AnnotationBuilder, "annotaterb/model_annotator/annotation_builder"
    autoload :ColumnAnnotation, "annotaterb/model_annotator/column_annotation"
    autoload :IndexAnnotation, "annotaterb/model_annotator/index_annotation"
    autoload :ForeignKeyAnnotation, "annotaterb/model_annotator/foreign_key_annotation"
    autoload :RelatedFilesListBuilder, "annotaterb/model_annotator/related_files_list_builder"
    autoload :AnnotationDecider, "annotaterb/model_annotator/annotation_decider"
    autoload :SingleFileAnnotatorInstruction, "annotaterb/model_annotator/single_file_annotator_instruction"
    autoload :SingleFileRemoveAnnotationInstruction, "annotaterb/model_annotator/single_file_remove_annotation_instruction"
    autoload :AnnotationDiffGenerator, "annotaterb/model_annotator/annotation_diff_generator"
    autoload :AnnotationDiff, "annotaterb/model_annotator/annotation_diff"
    autoload :ProjectAnnotator, "annotaterb/model_annotator/project_annotator"
    autoload :ProjectAnnotationRemover, "annotaterb/model_annotator/project_annotation_remover"
    autoload :AnnotatedFile, "annotaterb/model_annotator/annotated_file"
    autoload :FileParser, "annotaterb/model_annotator/file_parser"
    autoload :ZeitwerkClassGetter, "annotaterb/model_annotator/zeitwerk_class_getter"
    autoload :CheckConstraintAnnotation, "annotaterb/model_annotator/check_constraint_annotation"
    autoload :FileToParserMapper, "annotaterb/model_annotator/file_to_parser_mapper"
    autoload :Components, "annotaterb/model_annotator/components"
    autoload :Annotation, "annotaterb/model_annotator/annotation"
  end
end
