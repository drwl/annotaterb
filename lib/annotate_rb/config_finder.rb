# frozen_string_literal: true

require "pathname"

module AnnotateRb
  class ConfigFinder
    DOTFILE = ".annotaterb.yml"

    class << self
      def find_project_root
        # We should expect this method to be called from a Rails project root and returning it
        # e.g. "/Users/drwl/personal/annotaterb/dummyapp"
        Pathname.pwd
      end

      def find_project_dotfile
        [
          find_project_root.join(DOTFILE),
          find_project_root.join("config", DOTFILE.delete_prefix(".")),
          find_project_root.join(".config", DOTFILE),
          find_project_root.join(".config", "annotaterb", "config.yml")
        ].find(&:exist?)
      end
    end
  end
end
