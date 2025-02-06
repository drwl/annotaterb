# frozen_string_literal: true

module AnnotateRb
  class ConfigFinder
    DOTFILE = ".annotate_rb.yml"
    LEGACY_DOTFILE = ".annotaterb.yml"

    class << self
      def find_project_root
        # We should expect this method to be called from a Rails project root and returning it
        # e.g. "/Users/drwl/personal/annotate_rb/dummyapp"
        Dir.pwd
      end

      def find_project_dotfile
        file_path = File.expand_path(DOTFILE, find_project_root)
        legacy_file_path = File.expand_path(LEGACY_DOTFILE, find_project_root)

        if File.exist?(file_path)
          file_path 
        elsif File.exist?(legacy_file_path)
          legacy_file_path
        end
      end
    end
  end
end
