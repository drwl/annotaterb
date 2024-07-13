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
            if @options[:separate_associations] and not associations.empty?
              [
                MainHeader.new(version, @options[:include_version]),
                SchemaHeader.new(table_name, table_comment, @options),
                MarkdownHeader.new(max_size),
                *columns,
                AssociationsHeader.new,
                *associations,
                IndexAnnotation::AnnotationBuilder.new(@model, @options).build,
                ForeignKeyAnnotation::AnnotationBuilder.new(@model, @options).build,
                CheckConstraintAnnotation::AnnotationBuilder.new(@model, @options).build,
                SchemaFooter.new
              ]
            else
              [
                MainHeader.new(version, @options[:include_version]),
                SchemaHeader.new(table_name, table_comment, @options),
                MarkdownHeader.new(max_size),
                *columns,
                IndexAnnotation::AnnotationBuilder.new(@model, @options).build,
                ForeignKeyAnnotation::AnnotationBuilder.new(@model, @options).build,
                CheckConstraintAnnotation::AnnotationBuilder.new(@model, @options).build,
                SchemaFooter.new
              ]
            end
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

          def associations
            @model.associations.map do |assoc|
              _component = ColumnAnnotation::AnnotationBuilder.new(assoc, @model, max_size, @options).build
            end
          end
        end

        def initialize(klass, options)
          @model = ModelWrapper.new(klass, options)
          @options = options
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
