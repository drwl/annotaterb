# frozen_string_literal: true

module AnnotateRb
  class ConfigGenerator
    CONFIG_FILE = ConfigFinder::DOTFILE

    def generate_using_defaults
      defaults_hash = Options.from({}, {}).to_h
      yml_content = YAML.dump(defaults_hash, StringIO.new).string
      write_yml(CONFIG_FILE, yml_content)
    end

    # Returns boolean if the config file exists or not
    def config_file_exists?
      File.exist?(CONFIG_FILE)
    end

    def write_yml(file_name, yml_content)
      File.write(file_name, yml_content)
    end
  end
end
