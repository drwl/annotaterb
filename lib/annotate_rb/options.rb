# frozen_string_literal: true

require 'forwardable'

module AnnotateRb
  # Used to hold all of the options when annotating models and routes.
  # Should be the source of truth for what are valid options.
  class Options
    extend Forwardable

    class << self
      def from(options = {}, state = {})
        new(options, state).load_defaults
      end
    end

    POSITION_OPTIONS = {
      position: nil, # ModelAnnotator, RouteAnnotator
      position_in_class: nil, # ModelAnnotator
      position_in_factory: nil, # Unused
      position_in_fixture: nil, # Unused
      position_in_routes: nil, # RouteAnnotator
      position_in_serializer: nil, # Unused
      position_in_test: nil, # Unused
    }.freeze

    FLAG_OPTIONS = {
      classified_sort: true, # ModelAnnotator
      exclude_controllers: true, # Unused
      exclude_factories: false, # Unused
      exclude_fixtures: false, # Unused
      exclude_helpers: true, # Unused
      exclude_scaffolds: true, # Unused
      exclude_serializers: false, # Unused
      exclude_sti_subclasses: false, # ModelAnnotator
      exclude_tests: false, # Unused
      force: false, # ModelAnnotator, but should be used by both
      format_bare: true, # Unused
      format_markdown: false, # ModelAnnotator, RouteAnnotator
      format_rdoc: false, # ModelAnnotator
      format_yard: false, # ModelAnnotator
      frozen: false, # ModelAnnotator, but should be used by both
      ignore_model_sub_dir: false, # ModelAnnotator
      ignore_unknown_models: false, # ModelAnnotator
      include_version: false, # ModelAnnotator
      show_complete_foreign_keys: false, # ModelAnnotator
      show_foreign_keys: true, # ModelAnnotator
      show_indexes: true, # ModelAnnotator
      simple_indexes: false, # ModelAnnotator
      sort: false, # ModelAnnotator
      timestamp: false, # RouteAnnotator
      trace: false, # ModelAnnotator, but is part of Core
      with_comment: true, # ModelAnnotator
    }.freeze

    OTHER_OPTIONS = {
      active_admin: false, # ModelAnnotator
      command: nil, # Core
      debug: false, # Core

      # ModelAnnotator
      hide_default_column_types: '<%= ::AnnotateRb::ModelAnnotator::SchemaInfo::NO_DEFAULT_COL_TYPES.join(",") %>',

      # ModelAnnotator
      hide_limit_column_types: '<%= ::AnnotateRb::ModelAnnotator::SchemaInfo::NO_LIMIT_COL_TYPES.join(",") %>',

      ignore_columns: nil, # ModelAnnotator
      ignore_routes: nil, # RouteAnnotator
      ignore_unknown_models: false, # ModelAnnotator
      models: true, # Core
      routes: false, # Core
      skip_on_db_migrate: false, # Core
      target_action: :do_annotations, # Core; Possible values: :do_annotations, :remove_annotations
      wrapper: nil, # ModelAnnotator, RouteAnnotator
      wrapper_close: nil, # ModelAnnotator, RouteAnnotator
      wrapper_open: nil, # ModelAnnotator, RouteAnnotator
    }.freeze

    PATH_OPTIONS = {
      additional_file_patterns: [], # ModelAnnotator
      model_dir: ['app/models'], # ModelAnnotator
      require: [], # Core
      root_dir: [''], # Core; Old model Annotate code depends on it being empty when not provided another value
      # `root_dir` can also be a string but should get converted into an array with that string as the sole element when
      # that happens.
    }.freeze

    DEFAULT_OPTIONS = {}.merge(POSITION_OPTIONS, FLAG_OPTIONS, OTHER_OPTIONS, PATH_OPTIONS).freeze

    POSITION_OPTION_KEYS = [
      :position,
      :position_in_class,
      :position_in_routes,
    ].freeze

    FLAG_OPTION_KEYS = [
      :classified_sort,
      :exclude_sti_subclasses,
      :force,
      :format_markdown,
      :format_rdoc,
      :format_yard,
      :frozen,
      :ignore_model_sub_dir,
      :ignore_unknown_models,
      :include_version,
      :show_complete_foreign_keys,
      :show_foreign_keys,
      :show_indexes,
      :simple_indexes,
      :sort,
      :timestamp,
      :trace,
      :with_comment,
    ].freeze

    OTHER_OPTION_KEYS = [
      :active_admin,
      :command,
      :debug,
      :hide_default_column_types,
      :hide_limit_column_types,
      :ignore_columns,
      :ignore_routes,
      :ignore_unknown_models,
      :models,
      :routes,
      :skip_on_db_migrate,
      :target_action,
      :wrapper,
      :wrapper_close,
      :wrapper_open,
    ].freeze

    PATH_OPTION_KEYS = [
      :additional_file_patterns,
      :model_dir,
      :require,
      :root_dir,
    ].freeze

    ALL_OPTION_KEYS = [
      POSITION_OPTION_KEYS, FLAG_OPTION_KEYS, OTHER_OPTION_KEYS, PATH_OPTION_KEYS
    ].flatten.freeze

    POSITION_DEFAULT = 'before'

    # Want this to be read only after initializing
    def_delegator :@options, :[]

    def initialize(options = {}, state = {})
      @options = options

      # For now, state is a hash to store state that we need but is not a configuration option
      @state = state
    end

    def to_h
      @options.to_h
    end

    def load_defaults
      ALL_OPTION_KEYS.each do |key|
        @options[key] = DEFAULT_OPTIONS[key] unless @options.key?(key)
      end

      # Set all of the position options in the following order:
      # 1) Use the value if it's defined
      # 2) Use value from :position if it's defined
      # 3) Use default
      POSITION_OPTION_KEYS.each do |key|
        @options[key] = ModelAnnotator::Helper.fallback(
          @options[key], @options[:position], POSITION_DEFAULT
        )
      end

      # Unpack path options if we're passed in a String
      PATH_OPTION_KEYS.each do |key|
        if @options[key].is_a?(String)
          @options[key] = @options[key].split(',').map(&:strip).reject(&:empty?)
        end
      end

      # Set wrapper to default to :wrapper
      @options[:wrapper_open] ||= @options[:wrapper]
      @options[:wrapper_close] ||= @options[:wrapper]

      self
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
  end
end
