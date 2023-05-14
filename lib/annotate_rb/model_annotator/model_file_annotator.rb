# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Not sure yet what the difference is between this and FileAnnotator
    class ModelFileAnnotator
      class << self
        def call(annotated, file, options)
          begin
            return false if /#{Constants::SKIP_ANNOTATION_PREFIX}.*/ =~ (File.exist?(file) ? File.read(file) : '')
            klass = ModelClassGetter.call(file, options)

            klass_is_a_class = klass.is_a?(Class)
            klass_inherits_active_record_base = klass < ActiveRecord::Base
            klass_is_not_abstract = klass.respond_to?(:abstract_class) && !klass.abstract_class?
            klass_table_exists = klass.respond_to?(:abstract_class) && klass.table_exists?

            not_sure_this_conditional = (!options[:exclude_sti_subclasses] || !(klass.superclass < ActiveRecord::Base && klass.table_name == klass.superclass.table_name))

            annotate_conditions = [
              klass_is_a_class,
              klass_inherits_active_record_base,
              not_sure_this_conditional,
              klass_is_not_abstract,
              klass_table_exists
            ]

            do_annotate = annotate_conditions.all?

            if do_annotate
              files_annotated = annotate(klass, file, options)
              annotated.concat(files_annotated)
            end

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

            if FileAnnotator.call(model_file_name, info, :position_in_class, options)
              annotated << model_file_name
            end

            related_files = RelatedFilesListBuilder.new(file, model_name, table_name, options).build

            related_files.each do |f, position_key|
              if FileAnnotator.call(f, info, position_key, options)
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
