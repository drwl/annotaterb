# frozen_string_literal: true

module AnnotateRb
  class RakeBootstrapper
    class << self
      def call
        require "rake"

        load "./Rakefile" if File.exist?("./Rakefile") && !Rake::Task.task_defined?(:environment)

        begin
          Rake::Task[:environment].invoke
        rescue
          nil
        end

        # Tenanted models from activerecord-tenanted can't reach their database
        # without a current tenant. The gem defines `db:tenant` to set its default
        # tenant (ARTENANT, or the default tenant in local environments), the same
        # way it does for the Rails console.
        Rake::Task["db:tenant"].invoke if Rake::Task.task_defined?("db:tenant")
      end
    end
  end
end
