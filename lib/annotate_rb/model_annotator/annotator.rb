# require 'bigdecimal'

module AnnotateRb
  module ModelAnnotator
    class Annotator
      # Annotate Models plugin use this header
      PREFIX = '== Schema Information'.freeze
      PREFIX_MD = '## Schema Information'.freeze

      MAGIC_COMMENT_MATCHER = Regexp.new(/(^#\s*encoding:.*(?:\n|r\n))|(^# coding:.*(?:\n|\r\n))|(^# -\*- coding:.*(?:\n|\r\n))|(^# -\*- encoding\s?:.*(?:\n|\r\n))|(^#\s*frozen_string_literal:.+(?:\n|\r\n))|(^# -\*- frozen_string_literal\s*:.+-\*-(?:\n|\r\n))/).freeze

      class << self
        # Given the name of an ActiveRecord class, create a schema
        # info block (basically a comment containing information
        # on the columns and their types) and put it at the front
        # of the model and fixture source files.
        #
        # === Options (opts)
        #  :position_in_class<Symbol>:: where to place the annotated section in model file
        #  :position_in_test<Symbol>:: where to place the annotated section in test/spec file(s)
        #  :position_in_fixture<Symbol>:: where to place the annotated section in fixture file
        #  :position_in_factory<Symbol>:: where to place the annotated section in factory file
        #  :position_in_serializer<Symbol>:: where to place the annotated section in serializer file
        #  :exclude_tests<Symbol>:: whether to skip modification of test/spec files
        #  :exclude_fixtures<Symbol>:: whether to skip modification of fixture files
        #  :exclude_factories<Symbol>:: whether to skip modification of factory files
        #  :exclude_serializers<Symbol>:: whether to skip modification of serializer files
        #  :exclude_scaffolds<Symbol>:: whether to skip modification of scaffold files
        #  :exclude_controllers<Symbol>:: whether to skip modification of controller files
        #  :exclude_helpers<Symbol>:: whether to skip modification of helper files
        #  :exclude_sti_subclasses<Symbol>:: whether to skip modification of files for STI subclasses
        #
        # == Returns:
        # an array of file names that were annotated.
        #
        def annotate(klass, file, header, options = {})
          begin
            klass.reset_column_information
            info = SchemaInfo.generate(klass, header, options)
            model_name = klass.name.underscore
            table_name = klass.table_name
            model_file_name = File.join(file)
            annotated = []

            if AnnotateRb::ModelAnnotator::FileAnnotator.call(model_file_name, info, :position_in_class, options)
              annotated << model_file_name
            end

            Helper.matched_types(options).each do |key|
              exclusion_key = "exclude_#{key.pluralize}".to_sym
              position_key = "position_in_#{key}".to_sym

              # Same options for active_admin models
              if key == 'admin'
                exclusion_key = 'exclude_class'.to_sym
                position_key = 'position_in_class'.to_sym
              end

              next if options[exclusion_key]

              patterns = PatternGetter.call(options, key)

              patterns
                .map { |f| Helper.resolve_filename(f, model_name, table_name) }
                .map { |f| Dir.glob(f) }
                .flatten
                .each do |f|
                if AnnotateRb::ModelAnnotator::FileAnnotator.call(f, info, position_key, options)
                  annotated << f
                end
              end
            end
          rescue StandardError => e
            $stderr.puts "Unable to annotate #{file}: #{e.message}"
            $stderr.puts "\t" + e.backtrace.join("\n\t") if options[:trace]
          end

          annotated
        end

        # We're passed a name of things that might be
        # ActiveRecord models. If we can find the class, and
        # if its a subclass of ActiveRecord::Base,
        # then pass it to the associated block
        def do_annotations(options = {})
          header = options[:format_markdown] ? PREFIX_MD.dup : PREFIX.dup
          version = ActiveRecord::Migrator.current_version rescue 0
          if options[:include_version] && version > 0
            header << "\n# Schema version: #{version}"
          end

          annotated = []
          AnnotateRb::ModelAnnotator::ModelFilesGetter.call(options).each do |path, filename|
            annotate_model_file(annotated, File.join(path, filename), header, options)
          end

          if annotated.empty?
            puts 'Model files unchanged.'
          else
            puts "Annotated (#{annotated.length}): #{annotated.join(', ')}"
          end
        end

        def annotate_model_file(annotated, file, header, options)
          begin
            return false if /#{Constants::SKIP_ANNOTATION_PREFIX}.*/ =~ (File.exist?(file) ? File.read(file) : '')
            klass = AnnotateRb::ModelAnnotator::ModelClassGetter.call(file, options)
            do_annotate = klass.is_a?(Class) &&
              klass < ActiveRecord::Base &&
              (!options[:exclude_sti_subclasses] || !(klass.superclass < ActiveRecord::Base && klass.table_name == klass.superclass.table_name)) &&
              !klass.abstract_class? &&
              klass.table_exists?

            annotated.concat(annotate(klass, file, header, options)) if do_annotate
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

        def remove_annotations(options = {})
          deannotated = []
          deannotated_klass = false
          AnnotateRb::ModelAnnotator::ModelFilesGetter.call(options).each do |file|
            file = File.join(file)
            begin
              klass = AnnotateRb::ModelAnnotator::ModelClassGetter.call(file, options)
              if klass < ActiveRecord::Base && !klass.abstract_class?
                model_name = klass.name.underscore
                table_name = klass.table_name
                model_file_name = file
                deannotated_klass = true if FileAnnotationRemover.call(model_file_name, options)

                patterns = PatternGetter.call(options)

                patterns
                  .map { |f| Helper.resolve_filename(f, model_name, table_name) }
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

