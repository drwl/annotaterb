# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Compares the current file content and new annotation block and generates the column annotation differences
    class AnnotationDiffGenerator
      HEADER_PATTERN = /(^# Table name:.*?\n(#.*[\r]?\n)*[\r]?)/.freeze
      COLUMN_PATTERN = /^#[\t ]+[\w\*\.`\[\]():]+[\t ]+.+$/.freeze

      class << self
        def call(file_content, annotation_block)
          new(file_content, annotation_block).generate
        end
      end

      # @param [String] file_content The current file content of the model file we intend to annotate
      # @param [String] annotation_block The annotation block we intend to write to the model file
      def initialize(file_content, annotation_block)
        @file_content = file_content
        @annotation_block = annotation_block
      end

      def generate
        # Ignore the Schema version line because it changes with each migration
        current_annotations = @file_content.match(HEADER_PATTERN).to_s
        new_annotations = @annotation_block.match(HEADER_PATTERN).to_s

        if current_annotations.present?
          current_annotation_columns = current_annotations.scan(COLUMN_PATTERN).sort
        else
          current_annotation_columns = []
        end

        if new_annotations.present?
          new_annotation_columns = new_annotations.scan(COLUMN_PATTERN).sort
        else
          new_annotation_columns = []
        end

        _result = AnnotationDiff.new(current_annotation_columns, new_annotation_columns)
      end
    end
  end
end