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

    POSITION_OPTION_KEYS = [
      :position_in_routes, :position_in_class, :position_in_test,
      :position_in_fixture, :position_in_factory, :position,
      :position_in_serializer
    ].freeze

    FLAG_OPTION_KEYS = [
      :show_indexes, :simple_indexes, :include_version, :exclude_tests,
      :exclude_fixtures, :exclude_factories, :ignore_model_sub_dir,
      :format_bare, :format_rdoc, :format_yard, :format_markdown, :sort, :force, :frozen,
      :trace, :timestamp, :exclude_serializers, :classified_sort,
      :show_foreign_keys, :show_complete_foreign_keys,
      :exclude_scaffolds, :exclude_controllers, :exclude_helpers,
      :exclude_sti_subclasses, :ignore_unknown_models, :with_comment
    ].freeze

    OTHER_OPTION_KEYS = [
      :additional_file_patterns, :ignore_columns, :skip_on_db_migrate, :wrapper_open, :wrapper_close,
      :wrapper, :routes, :models, :hide_limit_column_types, :hide_default_column_types,
      :ignore_routes, :active_admin
    ].freeze

    PATH_OPTION_KEYS = [
      :require, :model_dir, :root_dir
    ].freeze

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
