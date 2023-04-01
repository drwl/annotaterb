# frozen_string_literal: true

module AnnotateRb
  # Raised when a RuboCop configuration file is not found.
  class ConfigNotFoundError < StandardError
  end

  class ConfigLoader
    class << self
      def load_config
        config_path = ConfigFinder.find_project_dotfile

        load_yaml_configuration(config_path)
      end

      # Method from Rubocop::ConfigLoader
      def load_yaml_configuration(absolute_path)
        file_contents = read_file(absolute_path)

        hash = yaml_safe_load(file_contents, absolute_path) || {}

        # TODO: Print config if debug flag/option is set

        raise(TypeError, "Malformed configuration in #{absolute_path}") unless hash.is_a?(Hash)

        hash
      end

      # Read the specified file, or exit with a friendly, concise message on
      # stderr. Care is taken to use the standard OS exit code for a "file not
      # found" error.
      #
      # Method from Rubocop::ConfigLoader
      def read_file(absolute_path)
        File.read(absolute_path, encoding: Encoding::UTF_8)
      rescue Errno::ENOENT
        raise ConfigNotFoundError, "Configuration file not found: #{absolute_path}"
      end

      # Method from Rubocop::ConfigLoader
      def yaml_safe_load(yaml_code, filename)
        yaml_safe_load!(yaml_code, filename)
      rescue ::StandardError
        if defined?(::SafeYAML)
          raise 'SafeYAML is unmaintained, no longer needed and should be removed'
        end

        raise
      end

      # Method from Rubocop::ConfigLoader
      def yaml_safe_load!(yaml_code, filename)
        YAML.safe_load(
          yaml_code, permitted_classes: [Regexp, Symbol], aliases: true, filename: filename
        )
      end
    end
  end
end
