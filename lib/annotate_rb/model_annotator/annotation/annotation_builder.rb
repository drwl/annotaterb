# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class AnnotationBuilder
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

          table_comment = @model.connection.try(:table_comment, @model.table_name)

          @info += if @options[:format_markdown]
            SchemaHeader.new(@model.table_name, table_comment, @options).to_markdown
          else
            SchemaHeader.new(@model.table_name, table_comment, @options).to_default
          end

          max_size = @model.max_schema_info_width

          if @options[:format_markdown]
            @info += MarkdownHeader.new(max_size).to_markdown
          end

          @info += @model.columns.map do |col|
            ColumnAnnotation::AnnotationBuilder.new(col, @model, max_size, @options).build
          end.join

          if @options[:show_indexes] && @model.table_exists?
            @info += IndexAnnotation::AnnotationBuilder.new(@model, @options).build
          end

          if @options[:show_foreign_keys] && @model.table_exists?
            foreign_key_annotation = ForeignKeyAnnotation::AnnotationBuilder.new(@model, @options).build

            @info += if @options[:format_markdown]
              foreign_key_annotation.to_markdown || ""
            else
              foreign_key_annotation.to_default || ""
            end
          end

          if @options[:show_check_constraints] && @model.table_exists?
            check_constraint_annotation = CheckConstraintAnnotation::AnnotationBuilder.new(@model, @options).build

            @info += if @options[:format_markdown]
              check_constraint_annotation.to_markdown || ""
            else
              check_constraint_annotation.to_default || ""
            end
          end

          @info += if @options[:format_rdoc]
            SchemaFooter.new.to_rdoc
          else
            SchemaFooter.new.to_default
          end

          @info
        end
      end
    end
  end
end
