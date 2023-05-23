# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ProjectAnnotator
      def initialize(options)
        @options = options
      end

      def annotate
        project_model_files = model_files

        annotation_instructions = project_model_files.map do |path, filename|
          file = File.join(path, filename)

          if AnnotationDecider.new(file, @options).annotate?
            _instructions = build_instructions_for_file(file)
          end
        end.flatten.compact

        annotated = annotation_instructions.map do |instruction|
          if SingleFileAnnotator.call_with_instructions(instruction)
            instruction.file
          end
        end.compact

        if annotated.empty?
          puts "Model files unchanged."
        else
          puts "Annotated (#{annotated.length}): #{annotated.join(", ")}"
        end
      end

      private

      def build_instructions_for_file(file)
        klass = ModelClassGetter.call(file, @options)

        instructions = []

        klass.reset_column_information
        annotation = AnnotationBuilder.new(klass, @options).build
        model_name = klass.name.underscore
        table_name = klass.table_name

        model_instruction = SingleFileAnnotatorInstruction.new(file, annotation, :position_in_class, @options)
        instructions << model_instruction

        related_files = RelatedFilesListBuilder.new(file, model_name, table_name, @options).build
        related_file_instructions = related_files.map do |f, position_key|
          _instruction = SingleFileAnnotatorInstruction.new(f, annotation, position_key, @options)
        end
        instructions.concat(related_file_instructions)

        instructions
      end

      def model_files
        @model_files ||= ModelFilesGetter.call(@options)
      end
    end
  end
end
