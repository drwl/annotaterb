# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module FileParser
      module AnnotationTarget
        SKIP_NAMES = %w[require require_relative load].freeze

        def self.find(parser, options)
          starts = parser.starts.reject { |entry| SKIP_NAMES.include?(entry.first) }
          return nil if starts.empty?

          return starts.first unless options[:nested_position] && parser.respond_to?(:type_map)

          class_entries = starts
            .select { |name, _line| parser.type_map[name] == :class }
            .uniq { |name, _line| name }

          class_entries.last || starts.first
        end
      end
    end
  end
end
