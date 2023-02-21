# require 'bigdecimal'

module AnnotateRb
  module ModelAnnotator
    class Annotator
      # Annotate Models plugin use this header
      PREFIX = '== Schema Information'.freeze
      PREFIX_MD = '## Schema Information'.freeze

      MAGIC_COMMENT_MATCHER = Regexp.new(/(^#\s*encoding:.*(?:\n|r\n))|(^# coding:.*(?:\n|\r\n))|(^# -\*- coding:.*(?:\n|\r\n))|(^# -\*- encoding\s?:.*(?:\n|\r\n))|(^#\s*frozen_string_literal:.+(?:\n|\r\n))|(^# -\*- frozen_string_literal\s*:.+-\*-(?:\n|\r\n))/).freeze

      class << self
        # Add a schema block to a file. If the file already contains
        # a schema info block (a comment starting with "== Schema Information"),
        # check if it matches the block that is already there. If so, leave it be.
        # If not, remove the old info block and write a new one.
        #
        # == Returns:
        # true or false depending on whether the file was modified.
        #
        # === Options (opts)
        #  :force<Symbol>:: whether to update the file even if it doesn't seem to need it.
        #  :position_in_*<Symbol>:: where to place the annotated section in fixture or model file,
        #                           :before, :top, :after or :bottom. Default is :before.
        #
        def annotate_one_file(file_name, info_block, position, options = {})
          return false unless File.exist?(file_name)
          old_content = File.read(file_name)
          return false if old_content =~ /#{Constants::SKIP_ANNOTATION_PREFIX}.*\n/

          # Ignore the Schema version line because it changes with each migration
          header_pattern = /(^# Table name:.*?\n(#.*[\r]?\n)*[\r]?)/
          old_header = old_content.match(header_pattern).to_s
          new_header = info_block.match(header_pattern).to_s

          column_pattern = /^#[\t ]+[\w\*\.`]+[\t ]+.+$/
          old_columns = old_header && old_header.scan(column_pattern).sort
          new_columns = new_header && new_header.scan(column_pattern).sort

          return false if old_columns == new_columns && !options[:force]

          abort "annotate error. #{file_name} needs to be updated, but annotate was run with `--frozen`." if options[:frozen]

          # Replace inline the old schema info with the new schema info
          wrapper_open = options[:wrapper_open] ? "# #{options[:wrapper_open]}\n" : ""
          wrapper_close = options[:wrapper_close] ? "# #{options[:wrapper_close]}\n" : ""
          wrapped_info_block = "#{wrapper_open}#{info_block}#{wrapper_close}"

          annotation_pattern = AnnotationPatternGenerator.call(options)
          old_annotation = old_content.match(annotation_pattern).to_s

          # if there *was* no old schema info or :force was passed, we simply
          # need to insert it in correct position
          if old_annotation.empty? || options[:force]
            magic_comments_block = Helper.magic_comments_as_string(old_content)
            old_content.gsub!(MAGIC_COMMENT_MATCHER, '')

            annotation_pattern = AnnotationPatternGenerator.call(options)
            old_content.sub!(annotation_pattern, '')

            new_content = if %w(after bottom).include?(options[position].to_s)
                            magic_comments_block + (old_content.rstrip + "\n\n" + wrapped_info_block)
                          elsif magic_comments_block.empty?
                            magic_comments_block + wrapped_info_block + old_content.lstrip
                          else
                            magic_comments_block + "\n" + wrapped_info_block + old_content.lstrip
                          end
          else
            # replace the old annotation with the new one

            # keep the surrounding whitespace the same
            space_match = old_annotation.match(/\A(?<start>\s*).*?\n(?<end>\s*)\z/m)
            new_annotation = space_match[:start] + wrapped_info_block + space_match[:end]

            annotation_pattern = AnnotationPatternGenerator.call(options)
            new_content = old_content.sub(annotation_pattern, new_annotation)
          end

          File.open(file_name, 'wb') { |f| f.puts new_content }
          true
        end

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

            if annotate_one_file(model_file_name, info, :position_in_class, options)
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
                if annotate_one_file(f, info, position_key, options)
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

        # Return a list of the model files to annotate.
        # If we have command line arguments, they're assumed to the path
        # of model files from root dir. Otherwise we take all the model files
        # in the model_dir directory.
        def get_model_files(options)
          model_files = []

          model_files = list_model_files_from_argument(options) unless options[:is_rake]

          return model_files unless model_files.empty?

          options[:model_dir].each do |dir|
            Dir.chdir(dir) do
              list = if options[:ignore_model_sub_dir]
                       Dir["*.rb"].map { |f| [dir, f] }
                     else
                       Dir["**/*.rb"].reject { |f| f["concerns/"] }.map { |f| [dir, f] }
                     end
              model_files.concat(list)
            end
          end

          model_files
        rescue SystemCallError
          $stderr.puts "No models found in directory '#{options[:model_dir].join("', '")}'."
          $stderr.puts "Either specify models on the command line, or use the --model-dir option."
          $stderr.puts "Call 'annotate --help' for more info."
          # exit 1 # TODO: Return exit code back to caller. Right now it messes up RSpec being able to run
        end

        def list_model_files_from_argument(options)
          return [] if ARGV.empty?

          specified_files = ARGV.map { |file| File.expand_path(file) }

          model_files = options[:model_dir].flat_map do |dir|
            absolute_dir_path = File.expand_path(dir)
            specified_files
              .find_all { |file| file.start_with?(absolute_dir_path) }
              .map { |file| [dir, file.sub("#{absolute_dir_path}/", '')] }
          end

          if model_files.size != specified_files.size
            $stderr.puts "The specified file could not be found in directory '#{options[:model_dir].join("', '")}'."
            $stderr.puts "Call 'annotate --help' for more info."
            # exit 1 # TODO: Return exit code back to caller. Right now it messes up RSpec being able to run
          end

          model_files
        end

        private :list_model_files_from_argument

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
          get_model_files(options).each do |path, filename|
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
          get_model_files(options).each do |file|
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

