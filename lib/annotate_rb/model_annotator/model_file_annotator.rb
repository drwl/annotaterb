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

            related_files = []
            types = %w(test fixture factory serializer scaffold controller helper)
            types << 'admin' if options[:active_admin] && !types.include?('admin')
            types << 'additional_file_patterns' if options[:additional_file_patterns].present?

            types.each do |key|
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
                .map { |f| FileNameResolver.call(f, model_name, table_name) }
                .map { |f| Dir.glob(f) }
                .flatten
                .each do |f|
                  related_files << [f, position_key]
              end
            end

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
