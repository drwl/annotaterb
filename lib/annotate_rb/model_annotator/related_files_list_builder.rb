# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Given a model file and options, this class will return a list of related files (e.g. fixture, controllers, etc)
    # to also annotate
    class RelatedFilesListBuilder
      RELATED_TYPES = %w[test fixture factory serializer scaffold controller helper].freeze

      def initialize(file, model_name, table_name, options)
        @file = file
        @model_name = model_name
        @table_name = table_name
        @options = options
      end

      def build
        @list = []

        add_related_test_files if !@options[:exclude_tests]
        add_related_fixture_files if !@options[:exclude_fixtures]
        add_related_factory_files if !@options[:exclude_factories]
        add_related_serializer_files if !@options[:exclude_serializers]
        add_related_scaffold_files if !@options[:exclude_scaffolds]
        add_related_controller_files if !@options[:exclude_controllers]
        add_related_helper_files if !@options[:exclude_helpers]
        add_related_admin_files if !@options[:active_admin]
        add_additional_file_patterns if @options[:additional_file_patterns].present?

        @list
      end

      private

      def related_files_for_pattern(pattern_type)
        patterns = PatternGetter.call(@options, pattern_type)

        patterns
          .map { |f| FileNameResolver.call(f, @model_name, @table_name) }
          .map { |f| Dir.glob(f) }
          .flatten
      end

      def add_related_test_files
        position_key = :position_in_test
        pattern_type = "test"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_fixture_files
        position_key = :position_in_fixture
        pattern_type = "fixture"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_factory_files
        position_key = :position_in_factory
        pattern_type = "factory"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_serializer_files
        position_key = :position_in_serializer
        pattern_type = "serializer"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_scaffold_files
        position_key = :position_in_scaffold # Key does not exist
        pattern_type = "scaffold"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_controller_files
        position_key = :position_in_controller # Key does not exist
        pattern_type = "controller"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_helper_files
        position_key = :position_in_helper # Key does not exist
        pattern_type = "helper"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_related_admin_files
        position_key = :position_in_admin # Key does not exist
        pattern_type = "admin"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end

      def add_additional_file_patterns
        position_key = :position_in_additional_file_patterns
        pattern_type = "additional_file_patterns"

        related_files = related_files_for_pattern(pattern_type)
        files_with_position_key = related_files.map { |f| [f, position_key] }

        @list.concat(files_with_position_key)
      end
    end
  end
end
