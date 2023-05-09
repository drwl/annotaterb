# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class AnnotationGenerator
      # Annotate Models plugin use this header
      PREFIX = '== Schema Information'.freeze
      PREFIX_MD = '## Schema Information'.freeze

      END_MARK = '== Schema Information End'.freeze

      MD_NAMES_OVERHEAD = 6
      MD_TYPE_ALLOWANCE = 18

      def initialize(klass, header, options)
        @header = header
        @options = options
        @model = ModelWrapper.new(klass, options)
        @info = "" # TODO: Make array and build string that way
      end

      def generate
        @info = "# #{header}\n"
        @info += schema_header_text

        max_size = @model.max_schema_info_width

        if @options[:format_markdown]
          @info += format("# %-#{max_size + MD_NAMES_OVERHEAD}.#{max_size + MD_NAMES_OVERHEAD}s | %-#{MD_TYPE_ALLOWANCE}.#{MD_TYPE_ALLOWANCE}s | %s\n",
                          'Name',
                          'Type',
                          'Attributes')
          @info += "# #{'-' * (max_size + MD_NAMES_OVERHEAD)} | #{'-' * MD_TYPE_ALLOWANCE} | #{'-' * 27}\n"
        end

        @info += @model.columns.map do |col|
          ColumnAnnotationBuilder.new(col, @model, max_size, @options).build
        end.join

        if @options[:show_indexes] && @model.table_exists?
          @info += IndexAnnotationBuilder.new(@model, @options).build
        end

        if @options[:show_foreign_keys] && @model.table_exists?
          @info += ForeignKeyAnnotationBuilder.new(@model, @options).build
        end

        @info += schema_footer_text

        @info
      end

      # TODO: Move header logic into here from AnnotateRb::ModelAnnotator::Annotator.do_annotations
      def header
        @header
      end

      def schema_header_text
        info = []
        info << "#"

        if @options[:format_markdown]
          info << "# Table name: `#{@model.table_name}`"
          info << "#"
          info << "# ### Columns"
        else
          info << "# Table name: #{@model.table_name}"
        end
        info << "#\n" # We want the last line break

        info.join("\n")
      end

      def schema_footer_text
        info = ''

        if @options[:format_rdoc]
          info += "#--\n"
          info += "# #{END_MARK}\n"
          info += "#++\n"
        else
          info += "#\n"
        end
      end
    end
  end
end