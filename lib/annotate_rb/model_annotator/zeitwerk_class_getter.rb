# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ZeitwerkClassGetter
      class << self
        def call(file, options)
          Rails.autoloaders.main.cpath_expected_at(file).constantize
        end
      end
    end
  end
end