# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Annotates a model file and its related files (controllers, factories, etc)
    class ModelFileAnnotator
      class << self
        def call(annotated, file, options)
          begin
            klass = ModelClassGetter.call(file, options)

            instructions = build_instructions(klass, file, options)
            instructions.each do |instruction|
              if FileAnnotator.call_with_instructions(instruction)
                annotated << instruction.file
              end
            end

            annotated
          rescue BadModelFileError => e
            unless options[:ignore_unknown_models]
              $stderr.puts "Unable to annotate #{file}: #{e.message}"
              $stderr.puts "\t" + e.backtrace.join("\n\t") if options[:trace]
            end
          rescue StandardError => e
            $stderr.puts "Unable to annotate #{file}: #{e.message}"
            $stderr.puts "\t" + e.backtrace.join("\n\t") if options[:trace]
          end
        end

        private

        def build_instructions(klass, file, options = {})
          instructions = []

          klass.reset_column_information
          annotation = AnnotationGenerator.new(klass, options).generate
          model_name = klass.name.underscore
          table_name = klass.table_name

          model_instruction = FileAnnotatorInstruction.new(file, annotation, :position_in_class, options)
          instructions << model_instruction

          related_files = RelatedFilesListBuilder.new(file, model_name, table_name, options).build
          related_file_instructions = related_files.map do |f, position_key|
            _instruction = FileAnnotatorInstruction.new(f, annotation, position_key, options)
          end
          instructions.concat(related_file_instructions)

          instructions
        end
      end
    end
  end
end
