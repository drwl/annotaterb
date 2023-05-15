# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Annotates a model file and its related files (controllers, factories, etc)
    class ModelFileAnnotator
      class << self
        def call(annotated, file, options)
          begin
            klass = ModelClassGetter.call(file, options)

            files_annotated = annotate(klass, file, options)
            annotated.concat(files_annotated)
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

        def annotate(klass, file, options = {})
          begin
            klass.reset_column_information
            info = AnnotationGenerator.new(klass, options).generate
            model_name = klass.name.underscore
            table_name = klass.table_name
            model_file_name = File.join(file)
            annotated = []

            instruction = FileAnnotatorInstruction.new(model_file_name, info, :position_in_class, options)
            if FileAnnotator.call_with_instructions(instruction)
              annotated << model_file_name
            end

            related_files = RelatedFilesListBuilder.new(file, model_name, table_name, options).build

            related_files.each do |f, position_key|
              instruction = FileAnnotatorInstruction.new(f, info, position_key, options)

              if FileAnnotator.call_with_instructions(instruction)
                annotated << f
              end
            end

          rescue StandardError => e
            $stderr.puts "Unable to annotate #{file}: #{e.message}"
            $stderr.puts "\t" + e.backtrace.join("\n\t") if options[:trace]
          end

          annotated
        end
      end
    end
  end
end
