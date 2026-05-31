# frozen_string_literal: true

require "annotate_rb"

module AnnotateRb
  module Generators
    class UpdateConfigGenerator < ::Rails::Generators::Base
      def generate_config
        parsed_options = AnnotateRb::Parser.parse(ARGV, {})
        AnnotateRb::ConfigFinder.config_path = parsed_options[:config_path] if parsed_options[:config_path]

        insert_into_file ::AnnotateRb::ConfigFinder.find_project_dotfile do
          ::AnnotateRb::ConfigGenerator.unset_config_defaults
        end
      end
    end
  end
end
