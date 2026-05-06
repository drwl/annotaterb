# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      # When `model_class_name` is given, matches that class declaration directly
      # so inner classes inside the model body cannot be mistaken for the target.
      module AnnotationTarget
        SKIP_NAMES = %w[require require_relative load].freeze

        def self.find(parser, options, model_class_name: nil)
          starts = parser.starts.reject { |entry| SKIP_NAMES.include?(entry.first) }
          return nil if starts.empty?

          return starts.first unless options[:nested_position] && parser.respond_to?(:type_map)

          if model_class_name && parser.type_map[model_class_name] == :class
            match = starts.find { |name, _line| name == model_class_name }
            return match if match
          end

          class_entries = starts
            .select { |name, _line| parser.type_map[name] == :class }
            .uniq { |name, _line| name }

          class_entries.last || starts.first
        end
      end
    end
  end
end
