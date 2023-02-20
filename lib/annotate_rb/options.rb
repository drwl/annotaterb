# frozen_string_literal: true

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
      position: 'before',
      position_in_class: 'before',
      position_in_factory: 'before',
      position_in_fixture: 'before',
      position_in_routes: 'before',
      position_in_serializer: 'before',
      position_in_test: 'before',
    }.freeze

    FLAG_OPTIONS = {
      classified_sort: true,
      exclude_controllers: true,
      exclude_factories: false,
      exclude_fixtures: false,
      exclude_helpers: true,
      exclude_scaffolds: true,
      exclude_serializers: false,
      exclude_sti_subclasses: false,
      exclude_tests: false,
      force: false,
      format_bare: true,
      format_markdown: false,
      format_rdoc: false,
      format_yard: false,
      frozen: false,
      ignore_model_sub_dir: false,
      ignore_unknown_models: false,
      include_version: false,
      show_complete_foreign_keys: false,
      show_foreign_keys: true,
      show_indexes: true,
      simple_indexes: false,
      sort: false,
      timestamp: false,
      trace: false,
      with_comment: true,
    }.freeze

    OTHER_OPTIONS = {
      active_admin: false,
      hide_default_column_types: '<%= ::AnnotateRb::ModelAnnotator::SchemaInfo::NO_DEFAULT_COL_TYPES.join(",") %>',
      hide_limit_column_types: '<%= ::AnnotateRb::ModelAnnotator::SchemaInfo::NO_LIMIT_COL_TYPES.join(",") %>',
      ignore_columns: nil,
      ignore_routes: nil,
      models: true,
      routes: false,
      skip_on_db_migrate: false,
      wrapper: nil,
      wrapper_close: nil,
      wrapper_open: nil,
    }.freeze

    PATH_OPTIONS = {
      additional_file_patterns: [],
      model_dir: 'app/models',
      require: [],
      root_dir: [],
    }.freeze

    DEFAULT_OPTIONS = {}.merge(POSITION_OPTIONS, FLAG_OPTIONS, OTHER_OPTIONS, PATH_OPTIONS).freeze

    POSITION_OPTION_KEYS = POSITION_OPTIONS.keys.freeze
    FLAG_OPTION_KEYS = FLAG_OPTIONS.keys.freeze
    OTHER_OPTION_KEYS = OTHER_OPTIONS.keys.freeze
    PATH_OPTION_KEYS = PATH_OPTIONS.keys.freeze

    ALL_OPTION_KEYS = [
      POSITION_OPTION_KEYS, FLAG_OPTION_KEYS, OTHER_OPTION_KEYS, PATH_OPTION_KEYS
    ].freeze

    # Want this to be read only after initializing
    def_delegator @options, :[]

    def initialize(options = {}, state = {})
      @options = options

      # For now, state is a hash to store state that we need but is not a configuration option
      @state = state
    end

    def load_defaults
      ALL_OPTION_KEYS.each do |key|
        @options[key] = DEFAULT_OPTIONS[key] unless @options.key?(key)
      end

      # Unpack path options if we're passed in a String
      PATH_OPTION_KEYS.each do |key|
        @options[key] = @options[key].split(',') if @options[key].is_a?(String)
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
