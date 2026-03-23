# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module EnumAnnotation
      class AnnotationBuilder
        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          return Components::NilComponent.new unless @options[:show_enums]

          enum_types = @model.enum_types
          return Components::NilComponent.new if enum_types.empty?

          # Filter to only enum types used by this table's columns
          table_enum_types = @model.columns.select { |col| col.type == :enum }
            .map { |col| col.sql_type.to_s }
            .uniq

          relevant_enums = enum_types
            .filter_map { |name, values| [name.to_s, values] if table_enum_types.include?(name.to_s) }
          return Components::NilComponent.new if relevant_enums.empty?

          max_size = relevant_enums.map { |name, _values| name.size }.max + 1

          components = relevant_enums.sort_by { |name, _values| name }.map do |name, values|
            EnumComponent.new(name, values, max_size)
          end

          Annotation.new(components)
        end
      end
    end
  end
end
