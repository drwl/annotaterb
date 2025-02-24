# frozen_string_literal: true

require "annotaterb"

module Annotaterb
  module Generators
    class HookGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_hook_file
        copy_file "annotaterb.rake", "lib/tasks/annotaterb.rake"
      end
    end
  end
end
