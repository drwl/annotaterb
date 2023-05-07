module AnnotateRb
  module ModelAnnotator
    module SchemaInfo # rubocop:disable Metrics/ModuleLength
      class << self
        # Use the column information in an ActiveRecord class
        # to create a comment block containing a line for
        # each column. The line contains the column name,
        # the type (and length), and any optional attributes
        def generate(klass, header, options = {})
          AnnotationGenerator.new(klass, header, options).generate
        end
      end
    end
  end
end
