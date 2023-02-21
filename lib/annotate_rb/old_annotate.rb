begin
  # ActiveSupport 3.x...
  require 'active_support/hash_with_indifferent_access'
  require 'active_support/core_ext/object/blank'
rescue StandardError
  # ActiveSupport 2.x...
  require 'active_support/core_ext/hash/indifferent_access'
  require 'active_support/core_ext/blank'
end

module AnnotateRb
  module OldAnnotate
    # Can be used by consumers, per README:
    #
    # To automatically annotate every time you run `db:migrate`,
    # either run `rails g annotate:install`
    # or add `Annotate.load_tasks` to your `Rakefile`.
    def self.load_tasks
      return if @tasks_loaded

      # Loads rake tasks, not sure why yet
      Dir[File.join(File.dirname(__FILE__), '..', 'tasks', '**/*.rake')].each do |rake|
        load rake
      end

      @tasks_loaded = true
    end

    def self.eager_load(options)
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

    def self.bootstrap_rake
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

      load_tasks

      # This line loads the defaults option values for Annotate
      # Then "writes" them to ENV if a value for them doesn't already exist
      #
      # Calls: .set_defaults
      Rake::Task[:set_annotation_options].invoke
    end
  end
end
