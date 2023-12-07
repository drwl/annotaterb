# frozen_string_literal: true

module AnnotateRb
  class ConfigGenerator
    class << self
      # Adds unset configuration key-value pairs to the config file.
      # Useful when a config file was generated an older version of gem and new
      #   settings get added.
      def unset_config_defaults
        _user_defaults_hash = ConfigLoader.load_config
        _defaults_hash = Options.from({}, {}).to_h
      end

      def default_config_yml
        defaults_hash = Options.from({}, {}).to_h
        _yml_content = YAML.dump(defaults_hash, StringIO.new).string
      end
    end
  end
end
