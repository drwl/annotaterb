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
              *enum_annotations,
              IndexAnnotation::AnnotationBuilder.new(@model, @options).build,
              ForeignKeyAnnotation::AnnotationBuilder.new(@model, @options).build,
              CheckConstraintAnnotation::AnnotationBuilder.new(@model, @options).build,
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

          def enum_annotations
            return [] unless @model.has_enums?

            [
              Components::Base.new.tap do |c|
                def c.to_default
                  "#\n# Enums"
                end
              end,
              *@model.enum_columns.map do |enum|
                Components::Base.new.tap do |c|
                  c.instance_variable_set(:@max_size, max_size)
                  c.define_singleton_method(:to_default) do
                    "#  #{enum[:name].ljust(@max_size)}  values: #{enum[:values].join(', ')}"
                  end
                end
              end
            ]
          end

          def columns
            @model.columns.map do |col|
              if col.type == :enum
                enum_info = @model.enum_columns.find { |e| e[:name] == col.name }
                _component = ColumnAnnotation::AnnotationBuilder.new(col, @model, max_size, @options, enum_info).build
              else
                _component = ColumnAnnotation::AnnotationBuilder.new(col, @model, max_size, @options).build
              end
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
