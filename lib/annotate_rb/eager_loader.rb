# frozen_string_literal: true

module AnnotateRb
  # Not sure what this does just yet
  class EagerLoader
    class << self
      def self.call(options)
        options[:require].count > 0 && options[:require].each { |path| require path }

        require 'annotate_rb/active_record_patch'

        if defined?(Rails::Application)
          klass = Rails::Application.send(:subclasses).first
          klass.eager_load!
        else
          options[:model_dir].each do |dir|
            FileList["#{dir}/**/*.rb"].each do |fname|
              require File.expand_path(fname)
            end
          end
        end
      end
    end
  end
end
