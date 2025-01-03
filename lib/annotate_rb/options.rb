# frozen_string_literal: true

require "forwardable"

module AnnotateRb
  # Used to hold all of the options when annotating models and routes.
  # Should be the source of truth for what are valid options.
  class Options
    extend Forwardable

    class << self
      def from(options = {}, state = {})
        new(options, state)
      end
    end

    POSITION_OPTIONS = {
      position: nil, # ModelAnnotator, RouteAnnotator
      position_in_additional_file_patterns: nil, # ModelAnnotator
      position_in_class: nil, # ModelAnnotator
      position_in_factory: nil, # ModelAnnotator
      position_in_fixture: nil, # ModelAnnotator
      position_in_routes: nil, # RouteAnnotator
      position_in_serializer: nil, # ModelAnnotator
      position_in_test: nil # ModelAnnotator
    }.freeze

    FLAG_OPTIONS = {
      classified_sort: true, # ModelAnnotator
      exclude_controllers: true, # ModelAnnotator
      exclude_factories: false, # ModelAnnotator
      exclude_fixtures: false, # ModelAnnotator
      exclude_helpers: true, # ModelAnnotator
      exclude_scaffolds: true, # ModelAnnotator
      exclude_serializers: false, # ModelAnnotator
      exclude_sti_subclasses: false, # ModelAnnotator
      exclude_tests: false, # ModelAnnotator
      force: false, # ModelAnnotator, but should be used by both
      format_markdown: false, # ModelAnnotator, RouteAnnotator
      format_rdoc: false, # ModelAnnotator
      format_yard: false, # ModelAnnotator
      frozen: false, # ModelAnnotator, but should be used by both
      ignore_model_sub_dir: false, # ModelAnnotator
      ignore_unknown_models: false, # ModelAnnotator
      include_version: false, # ModelAnnotator
      show_complete_foreign_keys: false, # ModelAnnotator
      show_check_constraints: false, # ModelAnnotator
      show_foreign_keys: true, # ModelAnnotator
      show_indexes: true, # ModelAnnotator
      simple_indexes: false, # ModelAnnotator
      sort: false, # ModelAnnotator
      timestamp: false, # RouteAnnotator
      trace: false, # ModelAnnotator, but is part of Core
      with_comment: true, # ModelAnnotator
      with_column_comments: nil, # ModelAnnotator
      with_table_comments: nil # ModelAnnotator
    }.freeze

    OTHER_OPTIONS = {
      active_admin: false, # ModelAnnotator
      command: nil, # Core
      debug: false, # Core

      # ModelAnnotator
      hide_default_column_types: "",

      # ModelAnnotator
      hide_limit_column_types: "",

      # ModelAnnotator
      timestamp_columns: ModelAnnotator::ModelWrapper::DEFAULT_TIMESTAMP_COLUMNS,

      ignore_columns: nil, # ModelAnnotator
      ignore_routes: nil, # RouteAnnotator
      ignore_unknown_models: false, # ModelAnnotator
      models: true, # Core
      routes: false, # Core
      skip_on_db_migrate: false, # Core
      target_action: :do_annotations, # Core; Possible values: :do_annotations, :remove_annotations
      wrapper: nil, # ModelAnnotator, RouteAnnotator
      wrapper_close: nil, # ModelAnnotator, RouteAnnotator
      wrapper_open: nil, # ModelAnnotator, RouteAnnotator,
      classes_default_to_s: [] # ModelAnnotator
    }.freeze

    PATH_OPTIONS = {
      additional_file_patterns: [], # ModelAnnotator
      model_dir: ["app/models"], # ModelAnnotator
      require: [], # Core
      root_dir: [""] # Core; Old model Annotate code depends on it being empty when not provided another value
      # `root_dir` can also be a string but should get converted into an array with that string as the sole element when
      # that happens.
    }.freeze

    DEFAULT_OPTIONS = {}.merge(POSITION_OPTIONS, FLAG_OPTIONS, OTHER_OPTIONS, PATH_OPTIONS).freeze

    POSITION_DEFAULT = "before"

    # Want this to be read only after initializing
    def_delegators :@options, :[], :to_h

    def initialize(options = {}, state = {})
      @options = options

      # For now, state is a hash to store state that we need but is not a configuration option
      @state = state

      load_defaults
      @options.freeze
    end

    def set_state(key, value, overwrite = false)
      if @state.key?(key) && !overwrite
        val = @state[key]
        raise ArgumentError, "Attempting to write '#{value}' to state with key '#{key}', but it already exists with '#{val}'."
      end

      @state[key] = value
    end

    def get_state(key)
      @state[key]
    end

    def print
      # TODO: prints options and state
    end

    private

    def load_defaults
      @options = DEFAULT_OPTIONS.merge(@options)

      # `:exclude_tests` option is being expanded to function as a boolean OR an array of symbols
      # https://github.com/drwl/annotaterb/issues/103
      if @options[:exclude_tests].is_a?(Array)
        @options[:exclude_tests].map! { |item| item.to_s.strip.to_sym }
      end

      # Set all of the position options in the following order:
      # 1) Use the value if it's defined
      # 2) Use value from :position if it's defined
      # 3) Use default
      POSITION_OPTIONS.each_key do |key|
        @options[key] = Helper.fallback(
          @options[key], @options[:position], POSITION_DEFAULT
        )
      end

      # Unpack path options if we're passed in a String
      PATH_OPTIONS.each_key do |key|
        if @options[key].is_a?(String)
          @options[key] = @options[key].split(",").map(&:strip).reject(&:empty?)
        end
      end

      # Set wrapper to default to :wrapper
      @options[:wrapper_open] ||= @options[:wrapper]
      @options[:wrapper_close] ||= @options[:wrapper]

      # Set column and table comments to default to :with_comment, if not set
      @options[:with_column_comments] = @options[:with_comment] if @options[:with_column_comments].nil?
      @options[:with_table_comments] = @options[:with_comment] if @options[:with_table_comments].nil?
    end
  end
end
