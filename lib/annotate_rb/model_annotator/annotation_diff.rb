# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Plain old Ruby object for holding the differences
    class AnnotationDiff
      attr_reader :old_columns, :new_columns

      def initialize(old_columns, new_columns)
        @old_columns = old_columns.dup.freeze
        @new_columns = new_columns.dup.freeze
      end

      def changed?
        @changed ||= @old_columns != @new_columns
      end
    end
  end
end