# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class FileNameResolver
      class << self
        def call(filename_template, model_name, table_name)
          filename_template
            .gsub('%MODEL_NAME%', model_name)
            .gsub('%PLURALIZED_MODEL_NAME%', model_name.pluralize)
            .gsub('%TABLE_NAME%', table_name || model_name.pluralize)
        end
      end
    end
  end
end
