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
    ##
    # Set default values that can be overridden via environment variables.
    #
    def self.set_defaults(options = {})
      return if @has_set_defaults
      @has_set_defaults = true

      options = ActiveSupport::HashWithIndifferentAccess.new(options)

      ModelAnnotator::Constants::ALL_ANNOTATE_OPTIONS.flatten.each do |key|
        if options.key?(key)
          default_value = if options[key].is_a?(Array)
                            options[key].join(',')
                          else
                            options[key]
                          end
        end

        default_value = Env.read(key) unless Env.read(key).blank?

        if default_value.nil?
          Env.write(key, nil)
        else
          Env.write(key, default_value.to_s)
        end
      end
    end

    ##
    # TODO: what is the difference between this and set_defaults?
    #
    def self.setup_options(options = {})
      ModelAnnotator::Constants::POSITION_OPTIONS.each do |key|
        options[key] = ModelAnnotator::Helper.fallback(Env.read(key), Env.read('position'), 'before')
      end
      ModelAnnotator::Constants::FLAG_OPTIONS.each do |key|
        options[key] = ModelAnnotator::Helper.true?(Env.read(key))
      end
      ModelAnnotator::Constants::OTHER_OPTIONS.each do |key|
        options[key] = !Env.read(key).blank? ? Env.read(key) : nil
      end
      ModelAnnotator::Constants::PATH_OPTIONS.each do |key|
        options[key] = !Env.read(key).blank? ? Env.read(key).split(',') : []
      end

      options[:additional_file_patterns] ||= []
      options[:additional_file_patterns] = options[:additional_file_patterns].split(',') if options[:additional_file_patterns].is_a?(String)
      options[:model_dir] = ['app/models'] if options[:model_dir].empty?

      options[:wrapper_open] ||= options[:wrapper]
      options[:wrapper_close] ||= options[:wrapper]

      # These were added in 2.7.0 but so this is to revert to old behavior by default
      options[:exclude_scaffolds] = ModelAnnotator::Helper.true?(Env.fetch('exclude_scaffolds', 'true'))
      options[:exclude_controllers] = ModelAnnotator::Helper.true?(Env.fetch('exclude_controllers', 'true'))
      options[:exclude_helpers] = ModelAnnotator::Helper.true?(Env.fetch('exclude_helpers', 'true'))

      options
    end

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
      load_requires(options)
      require 'annotate/active_record_patch'

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

    class << self
      private

      def load_requires(options)
        options[:require].count > 0 &&
          options[:require].each { |path| require path }
      end
    end
  end
end
