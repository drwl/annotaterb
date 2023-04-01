# frozen_string_literal: true

module AnnotateRb
  class ConfigFinder
    DOTFILE = '.annotaterb.yml'

    class << self
      def find_project_root
        # The user entry point is through `exe/annotaterb` so we should expect to be in the project root
        Dir.pwd
      end

      def find_project_dotfile
        file_path = File.expand_path(DOTFILE, find_project_root)

        return file_path if File.exist?(file_path)
      end
    end
  end
end
