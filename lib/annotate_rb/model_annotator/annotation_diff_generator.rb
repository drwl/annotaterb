# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Compares the current file content and new annotation block and generates the column annotation differences
    class AnnotationDiffGenerator
      HEADER_PATTERN = /(^# Table name:.*?\n(#.*[\r]?\n)*[\r]?)/.freeze
      COLUMN_PATTERN = /^#[\t ]+[\w\*\.`]+[\t ]+.+$/.freeze

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
        old_header = @file_content.match(HEADER_PATTERN).to_s
        new_header = @annotation_block.match(HEADER_PATTERN).to_s

        old_columns = old_header && old_header.scan(COLUMN_PATTERN).sort
        new_columns = new_header && new_header.scan(COLUMN_PATTERN).sort

        _result = AnnotationDiff.new(old_columns, new_columns)
      end
    end
  end
end