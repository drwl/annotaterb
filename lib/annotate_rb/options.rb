# frozen_string_literal: true

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
      position_in_routes: 'before',
      position_in_class: 'before',
      position_in_test: 'before',
      position_in_fixture: 'before',
      position_in_factory: 'before',
      position: 'before',
      position_in_serializer: 'before',
    }.freeze

    FLAG_OPTIONS = {
      show_indexes: true,
      simple_indexes: false,
      include_version: false,
      exclude_tests: false,
      exclude_fixtures: false,
      exclude_factories: false,
      exclude_serializers: false,
      exclude_scaffolds: true,
      exclude_controllers: true,
      exclude_helpers: true,
      exclude_sti_subclasses: false,
      ignore_model_sub_dir: false,
      format_bare: true,
      format_rdoc: false,
      format_yard: false,
      format_markdown: false,
      sort: false,
      force: false,
      frozen: false,
      trace: false,
      timestamp: false,
      classified_sort: true,
      show_foreign_keys: true,
      show_complete_foreign_keys: false,
      ignore_unknown_models: false,
      with_comment: true,
    }.freeze

    OTHER_OPTIONS = {
      additional_file_patterns: [],
      ignore_columns: nil,
      skip_on_db_migrate: false,
      wrapper_open: nil,
      wrapper_close: nil,
      wrapper: nil,
      routes: false,
      models: true,
      hide_limit_column_types: '<%= ::AnnotateRb::ModelAnnotator::SchemaInfo::NO_LIMIT_COL_TYPES.join(",") %>',
      hide_default_column_types: '<%= ::AnnotateRb::ModelAnnotator::SchemaInfo::NO_DEFAULT_COL_TYPES.join(",") %>',
      ignore_routes: nil,
      active_admin: false,
    }.freeze

    PATH_OPTIONS = {
      require: '',
      model_dir: 'app/models',
      root_dir: '',
    }.freeze

    POSITION_OPTION_KEYS = POSITION_OPTIONS.keys.freeze
    FLAG_OPTION_KEYS = FLAG_OPTIONS.keys.freeze
    OTHER_OPTION_KEYS = OTHER_OPTIONS.keys.freeze
    PATH_OPTION_KEYS = PATH_OPTIONS.keys.freeze

    ALL_OPTION_KEYS = [
      POSITION_OPTION_KEYS, FLAG_OPTION_KEYS, OTHER_OPTION_KEYS, PATH_OPTION_KEYS
    ].freeze

    def initialize(options = {}, state = {})
      @options = options

      # For now, state is a hash to store state that we need but is not a configuration option
      @state = state
    end

    # Want this to be read only after initializing
    def_delegator @options, :[]

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
