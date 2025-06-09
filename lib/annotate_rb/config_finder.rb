# frozen_string_literal: true

module AnnotateRb
  class ConfigFinder
    DOTFILE = ".annotaterb.yml"

    class << self
      attr_accessor :config_path

      def find_project_root
        # We should expect this method to be called from a Rails project root and returning it
        # e.g. "/Users/drwl/personal/annotaterb/dummyapp"
        Dir.pwd
      end

      def find_project_dotfile
        return @config_path if @config_path && File.exist?(@config_path)

        file_path = File.expand_path(DOTFILE, find_project_root)

        file_path if File.exist?(file_path)
      end
    end
  end
end
