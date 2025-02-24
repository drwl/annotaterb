# frozen_string_literal: true

require "annotaterb"

module Annotaterb
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      def install_hook_and_generate_defaults
        generate "annotaterb:hook"
        generate "annotaterb:config"
      end
    end
  end
end
