# frozen_string_literal: true

module AnnotateRb
  class ConfigFinder
    DOTFILE = ".annotaterb.yml"

    class << self
      def find_project_dotfile
        [
          Rails.root.join(DOTFILE),
          Rails.root.join(".config", DOTFILE),
          Rails.root.join(".config", "annotaterb", "config.yml")
        ].find(&:exist?)
      end
    end
  end
end
