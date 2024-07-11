# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class SchemaHeader < Components::Base
        attr_reader :table_name

        def initialize(table_name)
          @table_name = table_name
        end

        def to_markdown
          "#\n# Table name: `#{table_name}`\n#\n"
        end

        def to_default
          "#\n# Table name: #{table_name}\n#\n"
        end
      end
    end
  end
end
