# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class Annotator
      MAGIC_COMMENT_MATCHER = Regexp.new(/(^#\s*encoding:.*(?:\n|r\n))|(^# coding:.*(?:\n|\r\n))|(^# -\*- coding:.*(?:\n|\r\n))|(^# -\*- encoding\s?:.*(?:\n|\r\n))|(^#\s*frozen_string_literal:.+(?:\n|\r\n))|(^# -\*- frozen_string_literal\s*:.+-\*-(?:\n|\r\n))/).freeze

      class << self
        # We're passed a name of things that might be
        # ActiveRecord models. If we can find the class, and
        # if its a subclass of ActiveRecord::Base,
        # then pass it to the associated block
        def do_annotations(options = {})
          annotated = []

          # Currently ModelFilesGetter gets the model files we want to annotate. The list of model files then gets
          # expanded in ModelFileAnnotator. This is unintuitive.
          model_files_to_annotate = ModelFilesGetter.call(options)

          model_files_to_annotate.each do |path, filename|
            ModelFileAnnotator.call(annotated, File.join(path, filename), options)
          end

          if annotated.empty?
            puts 'Model files unchanged.'
          else
            puts "Annotated (#{annotated.length}): #{annotated.join(', ')}"
          end
        end

        def remove_annotations(options = {})
          deannotated = []
          deannotated_klass = false
          ModelFilesGetter.call(options).each do |file|
            file = File.join(file)
            begin
              klass = ModelClassGetter.call(file, options)
              if klass < ActiveRecord::Base && !klass.abstract_class?
                model_name = klass.name.underscore
                table_name = klass.table_name
                model_file_name = file
                deannotated_klass = true if FileAnnotationRemover.call(model_file_name, options)

                patterns = PatternGetter.call(options)

                patterns
                  .map { |f| FileNameResolver.call(f, model_name, table_name) }
                  .each do |f|
                  if File.exist?(f)
                    FileAnnotationRemover.call(f, options)
                    deannotated_klass = true
                  end
                end
              end
              deannotated << klass if deannotated_klass
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

