# frozen_string_literal: true

require "annotaterb"

module Annotaterb
  module Generators
    class UpdateConfigGenerator < ::Rails::Generators::Base
      def generate_config
        insert_into_file ::Annotaterb::ConfigFinder::DOTFILE do
          ::Annotaterb::ConfigGenerator.unset_config_defaults
        end
      end
    end
  end
end
