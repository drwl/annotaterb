# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Generates the text file content with annotations, these are then to be written to filesystem.
    class FileBuilder
      def initialize(file_components, annotation_position, options)
        @file_components = file_components
        @annotation_position = annotation_position
        @options = options
      end

      def generate_content_with_new_annotations
        AnnotatedFile::Generator.new(@file_components, @annotation_position, @options).generate
      end

      def update_existing_annotations
        AnnotatedFile::Updater.new(@file_components, @annotation_position, @options).update
      end
    end
  end
end
