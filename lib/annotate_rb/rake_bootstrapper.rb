# frozen_string_literal: true

module AnnotateRb
  class RakeBootstrapper
    class << self
      def call(options)
        begin
          require 'rake/dsl_definition'
        rescue StandardError => e
          # We might just be on an old version of Rake...
          $stderr.puts e.message
          exit e.status_code
        end
        require 'rake'

        load './Rakefile' if File.exist?('./Rakefile')
        begin
          Rake::Task[:environment].invoke
        rescue
          nil
        end
        unless defined?(Rails)
          # Not in a Rails project, so time to load up the parts of
          # ActiveSupport we need.
          require 'active_support'
          require 'active_support/core_ext/class/subclasses'
          require 'active_support/core_ext/string/inflections'
        end

        AnnotateRb::RakeTaskLoader.call(options)

        # This line loads the defaults option values for Annotate
        # Then "writes" them to ENV if a value for them doesn't already exist
        #
        # Calls: .set_defaults
        Rake::Task[:set_annotation_options].invoke
      end
    end
  end
end
