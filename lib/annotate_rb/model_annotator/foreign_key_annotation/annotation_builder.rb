# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module ForeignKeyAnnotation
      class AnnotationBuilder
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

          format_name = lambda do |fk|
            return fk.column if fk.name.blank?

            @options[:show_complete_foreign_keys] ? fk.name : fk.name.gsub(/(?<=^fk_rails_)[0-9a-f]{10}$/, "...")
          end

          max_size = foreign_keys.map(&format_name).map(&:size).max + 1
          foreign_keys.sort_by { |fk| [format_name.call(fk), stringify_columns(fk.column)] }.each do |fk|
            ref_info = if fk.column.is_a?(Array) # Composite foreign key using multiple columns
              "#{stringify_columns(fk.column)} => #{fk.to_table}#{stringify_columns(fk.primary_key)}"
            else
              "#{fk.column} => #{fk.to_table}.#{fk.primary_key}"
            end

            constraints_info = ""
            constraints_info += "ON DELETE => #{fk.on_delete} " if fk.on_delete
            constraints_info += "ON UPDATE => #{fk.on_update} " if fk.on_update
            constraints_info = constraints_info.strip

            fk_info += if @options[:format_markdown]
              format("# * `%s`%s:\n#     * **`%s`**\n",
                format_name.call(fk),
                constraints_info.blank? ? "" : " (_#{constraints_info}_)",
                ref_info)
            else
              format("#  %-#{max_size}.#{max_size}s %s %s",
                format_name.call(fk),
                "(#{ref_info})",
                constraints_info).rstrip + "\n"
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
