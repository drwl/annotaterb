# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ForeignKeyAnnotation
      class AnnotationBuilder
        class Annotation
          HEADER_TEXT = "Foreign Keys"

          def initialize(foreign_keys)
            @foreign_keys = foreign_keys
          end

          def body
            [
              Components::BlankLine.new,
              Components::Header.new(HEADER_TEXT),
              Components::BlankLine.new,
              *@foreign_keys,
              Components::LineBreak.new
            ]
          end

          def to_markdown
            body.map(&:to_markdown).join("\n")
          end

          def to_default
            body.map(&:to_default).join("\n")
          end
        end

        class ForeignKeyComponent < Components::Base
          attr_reader :formatted_name, :constraints_info, :ref_info, :max_size

          def initialize(formatted_name, constraints_info, ref_info, max_size)
            @formatted_name = formatted_name
            @constraints_info = constraints_info
            @ref_info = ref_info
            @max_size = max_size
          end

          def to_markdown
            format("# * `%s`%s:\n#     * **`%s`**",
              formatted_name,
              constraints_info.blank? ? "" : " (_#{constraints_info}_)",
              ref_info)
          end

          def to_default
            format("#  %-#{max_size}.#{max_size}s %s %s",
              formatted_name,
              "(#{ref_info})",
              constraints_info).rstrip
          end
        end

        class ForeignKeyComponentBuilder
          attr_reader :foreign_key

          def initialize(foreign_key, options)
            @foreign_key = foreign_key
            @options = options
          end

          def formatted_name
            @formatted_name ||= if foreign_key.name.blank?
              foreign_key.column
            else
              @options[:show_complete_foreign_keys] ? foreign_key.name : foreign_key.name.gsub(/(?<=^fk_rails_)[0-9a-f]{10}$/, "...")
            end
          end

          def stringified_columns
            @stringified_columns ||= stringify(foreign_key.column)
          end

          def stringified_primary_key
            @stringified_primary_key ||= stringify(foreign_key.primary_key)
          end

          def constraints_info
            @constraints_info ||= begin
              constraints_info = ""
              constraints_info += "ON DELETE => #{foreign_key.on_delete} " if foreign_key.on_delete
              constraints_info += "ON UPDATE => #{foreign_key.on_update} " if foreign_key.on_update
              constraints_info.strip
            end
          end

          def ref_info
            if foreign_key.column.is_a?(Array) # Composite foreign key using multiple columns
              "#{stringified_columns} => #{foreign_key.to_table}#{stringified_primary_key}"
            else
              "#{foreign_key.column} => #{foreign_key.to_table}.#{foreign_key.primary_key}"
            end
          end

          private

          # The fk columns or primary key might be composite (an Array), so format them into a string for the annotation
          def stringify(columns)
            columns.is_a?(Array) ? "[#{columns.join(", ")}]" : columns
          end
        end

        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          return "" unless @model.connection.respond_to?(:supports_foreign_keys?) &&
            @model.connection.supports_foreign_keys? && @model.connection.respond_to?(:foreign_keys)

          foreign_keys = @model.connection.foreign_keys(@model.table_name)
          return "" if foreign_keys.empty?

          fks = foreign_keys.map do |fk|
            ForeignKeyComponentBuilder.new(fk, @options)
          end

          max_size = fks.map(&:formatted_name).map(&:size).max + 1

          foreign_key_components = fks.sort_by { |fk| [fk.formatted_name, fk.stringified_columns] }.map do |fk|
            # fk is a ForeignKeyComponentBuilder

            ForeignKeyComponent.new(fk.formatted_name, fk.constraints_info, fk.ref_info, max_size)
          end

          if @options[:format_markdown]
            Annotation.new(foreign_key_components).to_markdown
          else
            Annotation.new(foreign_key_components).to_default
          end
        end
      end
    end
  end
end
