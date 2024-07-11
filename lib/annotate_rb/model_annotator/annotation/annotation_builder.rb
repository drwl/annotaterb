# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class AnnotationBuilder
        END_MARK = "== Schema Information End"

        MD_NAMES_OVERHEAD = 6
        MD_TYPE_ALLOWANCE = 18

        def initialize(klass, options)
          @model = ModelWrapper.new(klass, options)
          @options = options
          @info = "" # TODO: Make array and build string that way
        end

        def build
          if @options.get_state(:current_version).nil?
            migration_version = begin
              ActiveRecord::Migrator.current_version
            rescue
              0
            end

            @options.set_state(:current_version, migration_version)
          end

          version = @options.get_state(:current_version)

          @info = if @options[:format_markdown]
            MainHeader.new(version, @options[:include_version]).to_markdown
          else
            MainHeader.new(version, @options[:include_version]).to_default
          end

          @info += "\n"
          @info += schema_header_text

          max_size = @model.max_schema_info_width

          if @options[:format_markdown]
            @info += "# ### Columns\n"
            @info += "#\n"
            # standard:disable Lint/FormatParameterMismatch
            @info += format("# %-#{max_size + MD_NAMES_OVERHEAD}.#{max_size + MD_NAMES_OVERHEAD}s | %-#{MD_TYPE_ALLOWANCE}.#{MD_TYPE_ALLOWANCE}s | %s\n",
              "Name",
              "Type",
              "Attributes")
            # standard:enable Lint/FormatParameterMismatch
            @info += "# #{"-" * (max_size + MD_NAMES_OVERHEAD)} | #{"-" * MD_TYPE_ALLOWANCE} | #{"-" * 27}\n"
          end

          @info += @model.columns.map do |col|
            ColumnAnnotation::AnnotationBuilder.new(col, @model, max_size, @options).build
          end.join

          if @options[:show_indexes] && @model.table_exists?
            @info += IndexAnnotation::AnnotationBuilder.new(@model, @options).build
          end

          if @options[:show_foreign_keys] && @model.table_exists?
            @info += ForeignKeyAnnotation::AnnotationBuilder.new(@model, @options).build
          end

          if @options[:show_check_constraints] && @model.table_exists?
            @info += CheckConstraintAnnotation::AnnotationBuilder.new(@model, @options).build
          end

          @info += schema_footer_text

          @info
        end

        def schema_header_text
          if @options[:format_markdown]
            SchemaHeader.new(table_name).to_markdown
          else
            SchemaHeader.new(table_name).to_default
          end
        end

        def schema_footer_text
          info = []

          if @options[:format_rdoc]
            info << "#--"
            info << "# #{END_MARK}"
            info << "#++\n"
          else
            info << "#\n"
          end

          info.join("\n")
        end

        private

        def table_name
          table_name = @model.table_name
          display_table_comments = @options[:with_comment] && @options[:with_table_comments]

          if display_table_comments && @model.has_table_comments?
            table_comment = "(#{@model.table_comments.gsub(/\n/, "\\n")})"
            table_name = "#{table_name}#{table_comment}"
          end

          table_name
        end
      end
    end
  end
end
