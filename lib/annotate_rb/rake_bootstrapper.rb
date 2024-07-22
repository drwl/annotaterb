# frozen_string_literal: true

module AnnotateRb
  class RakeBootstrapper
    class << self
      def call(options)
        require "rake"
        load "./Rakefile" if File.exist?("./Rakefile")

        begin
          Rake::Task[:environment].invoke
        rescue
          nil
        end
      end
    end
  end
end
