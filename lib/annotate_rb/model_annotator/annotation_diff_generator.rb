# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Compares the current file content and new annotation block and generates the column annotation differences
    class AnnotationDiffGenerator
      # @param [String] file_content The current file content of the model file we intend to annotate
      # @param [String] annotation_block The annotation block we intend to write to the model file
      def initialize(file_content, annotation_block)
        @file_content = file_content
        @annotation_block = annotation_block
      end

      def generate
        # Ignore the Schema version line because it changes with each migration
        header_pattern = /(^# Table name:.*?\n(#.*[\r]?\n)*[\r]?)/
        old_header = @file_content.match(header_pattern).to_s
        new_header = @annotation_block.match(header_pattern).to_s

        column_pattern = /^#[\t ]+[\w\*\.`]+[\t ]+.+$/
        old_columns = old_header && old_header.scan(column_pattern).sort
        new_columns = new_header && new_header.scan(column_pattern).sort

        [old_columns, new_columns]
      end
    end
  end
end