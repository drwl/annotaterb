module AnnotateRb
  module ModelAnnotator
    class AnnotationGenerator
      # Annotate Models plugin use this header
      PREFIX = '== Schema Information'.freeze
      PREFIX_MD = '## Schema Information'.freeze

      def initialize(klass, header, options)
        @klass = klass
        @header = header
        @options = options
        @model_thing = ModelThing.new(klass, options)
        # @info = []
        @info = "" # TODO: Make array and build string that way
      end

      def generate

      end

      # TODO: Move header logic into here from AnnotateRb::ModelAnnotator::Annotator.do_annotations
      def header
        @header
      end

      def schema_header_text
        info = []
        info << "#"

        if @options[:format_markdown]
          info << "# Table name: `#{@model_thing.table_name}`"
          info << "#"
          info << "# ### Columns"
        else
          info << "# Table name: #{@model_thing.table_name}"
        end
        info << "#\n" # We want the last line break

        info.join("\n")
      end
    end
  end
end