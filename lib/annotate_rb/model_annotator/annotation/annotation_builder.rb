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

          def columns
            @model.columns.map do |col|
              _component = ColumnAnnotation::AnnotationBuilder.new(col, @model, max_size, @options).build
            end
          end
        end

        def initialize(klass, options)
          @model = ModelWrapper.new(klass, options)
          @options = options
        end

        def build
          version = migration_version_for_model(@model)
          table_name = @model.table_name
          table_comment = @model.connection.try(:table_comment, @model.table_name)
          max_size = @model.max_schema_info_width

          _annotation = Annotation.new(@options,
            version: version, table_name: table_name, table_comment: table_comment,
            max_size: max_size, model: @model).build
        end

        private

        def migration_version_for_model(model)
          return 0 unless @options[:include_version]

          # Multi-database support: Cache migration versions per database connection to handle
          # different schema versions across primary/secondary databases correctly.
          # Example: primary → "current_version_primary", secondary → "current_version_secondary"
          connection_pool_name = model.connection.pool.db_config.name
          cache_key = "current_version_#{connection_pool_name}".to_sym

          if @options.get_state(cache_key).nil?
            migration_version = begin
              model.connection.migration_context.current_version
            rescue
              0
            end

            @options.set_state(cache_key, migration_version)
          end

          @options.get_state(cache_key)
        end
      end
    end
  end
end
