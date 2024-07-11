# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Annotation
      class AnnotationBuilder
        class Annotation < Components::Base
          attr_reader :version, :table_name, :table_comment, :max_size

          def initialize(options, **input)
            @options = options

            @version = input[:version]
            @table_name = input[:table_name]
            @table_comment = input[:table_comment]
            @max_size = input[:max_size]
            @model = input[:model]
          end

          def body
            [
              MainHeader.new(version, @options[:include_version]),
              SchemaHeader.new(table_name, table_comment, @options),
              MarkdownHeader.new(max_size),
              *columns,
              indexes,
              foreign_keys,
              check_constraints,
              SchemaFooter.new
            ]
          end

          def build
            components = body.flatten

            if @options[:format_rdoc]
              components.map(&:to_rdoc).compact.join("\n")
            elsif @options[:format_yard]
              components.map(&:to_yard).compact.join("\n")
            elsif @options[:format_markdown]
              components.map(&:to_markdown).compact.join("\n")
            else
              components.map(&:to_default).compact.join("\n")
            end
          end

          private

          def columns
            @model.columns.map do |col|
              _component = ColumnAnnotation::AnnotationBuilder.new(col, @model, max_size, @options).build
            end
          end

          def indexes
            if @options[:show_indexes] && @model.table_exists?
              _index_annotation = IndexAnnotation::AnnotationBuilder.new(@model, @options).build
            else
              Components::NilComponent.new
            end
          end

          def foreign_keys
            if @options[:show_foreign_keys] && @model.table_exists?
              _foreign_key_annotation = ForeignKeyAnnotation::AnnotationBuilder.new(@model, @options).build
            else
              Components::NilComponent.new
            end
          end

          def check_constraints
            if @options[:show_check_constraints] && @model.table_exists?
              _check_constraint_annotation = CheckConstraintAnnotation::AnnotationBuilder.new(@model, @options).build
            else
              Components::NilComponent.new
            end
          end
        end

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
          table_name = @model.table_name
          table_comment = @model.connection.try(:table_comment, @model.table_name)
          max_size = @model.max_schema_info_width

          _annotation = Annotation.new(@options,
            version: version, table_name: table_name, table_comment: table_comment,
            max_size: max_size, model: @model).build
        end
      end
    end
  end
end
