# frozen_string_literal: true

module AnnotateRb
  module Core
    class << self
      def version
        @version ||= File.read(File.expand_path('../../VERSION', __dir__)).strip
      end
    end
  end
end