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
          model_files = []

          model_files = list_model_files_from_argument(options) if !options[:is_rake]

          return model_files if !model_files.empty?

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

        private

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
      end
    end
  end
end
