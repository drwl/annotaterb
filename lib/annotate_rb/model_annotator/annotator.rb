# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class Annotator
      class << self
        def do_annotations(options = {})
          annotated = []

          model_files_to_consider = ModelFilesGetter.call(options)

          model_files_to_consider.each do |path, filename|
            file = File.join(path, filename)

            if AnnotationDecider.new(file, options).annotate?
              ModelFileAnnotator.call(annotated, file, options)
            end
          end

          if annotated.empty?
            puts 'Model files unchanged.'
          else
            puts "Annotated (#{annotated.length}): #{annotated.join(', ')}"
          end
        end

        def remove_annotations(options = {})
          deannotated = []

          model_files_to_consider = ModelFilesGetter.call(options)

          model_files_to_consider.each do |path, filename|
            deannotated_klass = false
            file = File.join(path, filename)

            begin
              klass = ModelClassGetter.call(file, options)
              if klass < ActiveRecord::Base && !klass.abstract_class?
                model_name = klass.name.underscore
                table_name = klass.table_name

                if FileAnnotationRemover.call(file, options)
                  deannotated_klass = true
                end

                related_files = RelatedFilesListBuilder.new(file, model_name, table_name, options).build

                related_files.each do |f, _position_key|
                  if File.exist?(f)
                    FileAnnotationRemover.call(f, options)
                  end
                end
              end

              if deannotated_klass
                deannotated << klass
              end
            rescue StandardError => e
              $stderr.puts "Unable to deannotate #{File.join(file)}: #{e.message}"
              $stderr.puts "\t" + e.backtrace.join("\n\t") if options[:trace]
            end
          end

          puts "Removed annotations from: #{deannotated.join(', ')}"
        end
      end
    end
  end
end

