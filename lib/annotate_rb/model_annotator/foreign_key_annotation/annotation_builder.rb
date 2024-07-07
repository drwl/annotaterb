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
          attr_reader :foreign_key, :max_size

          def initialize(foreign_key, max_size, options)
            @foreign_key = foreign_key
            @max_size = max_size
            @options = options
          end

          private

          def format_name
            return foreign_key.column if foreign_key.name.blank?

            @options[:show_complete_foreign_keys] ? foreign_key.name : foreign_key.name.gsub(/(?<=^fk_rails_)[0-9a-f]{10}$/, "...")
          end

          # The fk columns might be composite keys, so format them into a string for the annotation
          def stringify_columns(columns)
            columns.is_a?(Array) ? "[#{columns.join(", ")}]" : columns
          end
        end

        Foo = Struct.new(:foreign_key, :options) do
          def formatted_name
            @formatted_name ||= if foreign_key.name.blank?
              foreign_key.column
            else
              options[:show_complete_foreign_keys] ? foreign_key.name : foreign_key.name.gsub(/(?<=^fk_rails_)[0-9a-f]{10}$/, "...")
            end
          end

          def stringified_columns
            @stringified_columns ||= begin
              # The fk columns might be composite keys, so format them into a string for the annotation
              columns = foreign_key.column
              columns.is_a?(Array) ? "[#{columns.join(", ")}]" : columns
            end
          end

          def stringified_primary_key
            @stringified_primary_key ||= begin
              columns = foreign_key.primary_key
              columns.is_a?(Array) ? "[#{columns.join(", ")}]" : columns
            end
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
        end

        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          fk_info = if @options[:format_markdown]
            "#\n# ### Foreign Keys\n#\n"
          else
            "#\n# Foreign Keys\n#\n"
          end

          return "" unless @model.connection.respond_to?(:supports_foreign_keys?) &&
            @model.connection.supports_foreign_keys? && @model.connection.respond_to?(:foreign_keys)

          foreign_keys = @model.connection.foreign_keys(@model.table_name)
          return "" if foreign_keys.empty?

          fks = foreign_keys.map do |fk|
            Foo.new(fk, @options)
          end

          max_size = fks.map(&:formatted_name).map(&:size).max + 1

          fks.sort_by { |fk| [fk.formatted_name, fk.stringified_columns] }.each do |fk|
            fk_info += if @options[:format_markdown]
              format("# * `%s`%s:\n#     * **`%s`**\n",
                fk.formatted_name,
                fk.constraints_info.blank? ? "" : " (_#{fk.constraints_info}_)",
                fk.ref_info)
            else
              format("#  %-#{max_size}.#{max_size}s %s %s",
                fk.formatted_name,
                "(#{fk.ref_info})",
                fk.constraints_info).rstrip + "\n"
            end
          end

          fk_info
        end

        private

        # The fk columns might be composite keys, so format them into a string for the annotation
        def stringify_columns(columns)
          columns.is_a?(Array) ? "[#{columns.join(", ")}]" : columns
        end
      end
    end
  end
end
