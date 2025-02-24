# frozen_string_literal: true

require "annotaterb"

module Annotaterb
  module Generators
    class ConfigGenerator < ::Rails::Generators::Base
      def generate_config
        create_file ::Annotaterb::ConfigFinder::DOTFILE do
          ::Annotaterb::ConfigGenerator.default_config_yml
        end
      end
    end
  end
end
