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

          options[:model_dir].each do |dir|
            dir_is_glob = dir.include?("*")

            if dir_is_glob
              Dir.glob(dir).each do |sub_dir|
                Dir.chdir(sub_dir) do
                  list = if options[:ignore_model_sub_dir]
                    Dir["*.rb"].map { |f| [sub_dir, f] }
                  else
                    Dir["**/*.rb"]
                      .reject { |f| f["concerns/"] }
                      .map { |f| [sub_dir, f] }
                  end
                  model_files.concat(list)
                end
              end
            else
            Dir.chdir(dir) do
              list = if options[:ignore_model_sub_dir]
                Dir["*.rb"].map { |f| [dir, f] }
              else
                Dir["**/*.rb"]
                  .reject { |f| f["concerns/"] }
                  .map { |f| [dir, f] }
              end
              model_files.concat(list)
            end
          end
          end

          model_files
        rescue SystemCallError
          warn "No models found in directory '#{options[:model_dir].join("', '")}'."
          warn "Either specify models on the command line, or use the --model-dir option."
          warn "Call 'annotaterb --help' for more info."
          # exit 1 # TODO: Return exit code back to caller. Right now it messes up RSpec being able to run
        end

        private

        def list_model_files_from_argument(options)
          working_args = options.get_state(:working_args)
          return [] if working_args.empty?

          specified_files = working_args.map { |file| File.expand_path(file) }

          model_files = options[:model_dir].flat_map do |dir|
            absolute_dir_path = File.expand_path(dir)
            specified_files
              .find_all { |file| file.start_with?(absolute_dir_path) }
              .map { |file| [dir, file.sub("#{absolute_dir_path}/", "")] }
          end

          if model_files.size != specified_files.size
            warn "The specified file could not be found in directory '#{options[:model_dir].join("', '")}'."
            warn "Call 'annotaterb --help' for more info."
            # exit 1 # TODO: Return exit code back to caller. Right now it messes up RSpec being able to run
          end

          model_files
        end
      end
    end
  end
end
