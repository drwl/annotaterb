# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ModelFilesGetter
      class << self
        # Return a list of the model files to annotate.
        # If we have command line arguments, they're assumed to the path
        # of model files from root dir. Otherwise we take all the model files
        # in the model_dir directory.
        def call(options)
          model_files = list_model_files_from_argument(options)

          return model_files if model_files.any?

          model_directory_patterns = options[:model_dir]
          found_dirs = model_directory_patterns.flat_map { |pattern| Dir.glob(pattern) }.select { |entry| File.directory?(entry) }.uniq

          found_dirs.each do |dir|
            search_pattern = options[:ignore_model_sub_dir] ? File.join(dir, "*.rb") : File.join(dir, "**/*.rb")

            Dir.glob(search_pattern).each do |file_path|
              next unless File.file?(file_path)
              next if !options[:ignore_model_sub_dir] && file_path.include?(File.join(dir, "concerns/"))

              # Calculate relative path from the original pattern's base or the found dir
              # For simplicity, let's use the found dir as the base for the relative path calculation
              relative_path = file_path.sub(%r{^#{Regexp.escape(dir)}/?}, "")
              model_files << [dir, relative_path]
            end
          end

          model_files
        rescue SystemCallError => e
          warn "Error while searching for models: #{e.message}"
          warn "Searched patterns: '#{options[:model_dir].join("', '")}'."
          warn "Either specify models on the command line, or use the --model-dir option."
          warn "Call 'annotaterb --help' for more info."
          # exit 1 # TODO: Return exit code back to caller. Right now it messes up RSpec being able to run
        end

        private

        def list_model_files_from_argument(options)
          return [] if options.get_state(:working_args).empty?

          specified_files = options.get_state(:working_args).map { |file| File.expand_path(file) }
          model_directory_patterns = options[:model_dir]
          found_dirs = model_directory_patterns.flat_map { |pattern| Dir.glob(pattern) }.select { |entry| File.directory?(entry) }.uniq

          model_files = found_dirs.flat_map do |dir|
            absolute_dir_path = File.expand_path(dir)
            specified_files
              .find_all { |file| file.start_with?(absolute_dir_path) }
              .map { |file| [dir, file.sub(%r{^#{Regexp.escape(absolute_dir_path)}/?}, "")] }
          end

          if model_files.size != specified_files.size
            missing_files = specified_files - model_files.map { |dir, rel_path| File.expand_path(rel_path, dir) }
            warn "The specified file(s) could not be found in any directory matching patterns '#{model_directory_patterns.join("', '")}'': #{missing_files.join(', ')}."
            warn "Call 'annotaterb --help' for more info."
            # exit 1 # TODO: Return exit code back to caller. Right now it messes up RSpec being able to run
          end

          model_files
        end
      end
    end
  end
end
