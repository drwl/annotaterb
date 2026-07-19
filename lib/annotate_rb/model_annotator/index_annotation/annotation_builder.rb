# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module IndexAnnotation
      class AnnotationBuilder
        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          return Components::NilComponent.new if !@options[:show_indexes]

          indexes = @model.retrieve_indexes_from_table
          return Components::NilComponent.new if indexes.empty?

          indexes = reject_constraint_backed_indexes(indexes)
          return Components::NilComponent.new if indexes.empty?

          max_size = indexes.map { |index| index.name.size }.max + 1

          indexes = indexes.sort_by(&:name).map do |index|
            IndexComponent.new(index, max_size, @options)
          end

          _annotation = Annotation.new(indexes)
        end

        private

        # Mirrors ActiveRecord's schema_dumper#indexes_in_create: PostgreSQL's
        # unique and exclusion constraints are backed by indexes with the same
        # name, so those show up in `connection.indexes` too. Drop them here so
        # they only appear under their dedicated sections.
        def reject_constraint_backed_indexes(indexes)
          connection = @model.connection

          if connection.respond_to?(:supports_exclusion_constraints?) &&
              connection.supports_exclusion_constraints? &&
              connection.respond_to?(:exclusion_constraints)
            excl_names = connection.exclusion_constraints(@model.table_name).map(&:name)
            indexes = indexes.reject { |index| excl_names.include?(index.name) }
          end

          if connection.respond_to?(:supports_unique_constraints?) &&
              connection.supports_unique_constraints? &&
              connection.respond_to?(:unique_constraints)
            unique_names = connection.unique_constraints(@model.table_name).map(&:name)
            indexes = indexes.reject { |index| unique_names.include?(index.name) }
          end

          indexes
        end
      end
    end
  end
end
