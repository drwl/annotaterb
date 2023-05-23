# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module IndexAnnotation
      class AnnotationBuilder
        INDEX_CLAUSES = {
          unique: {
            default: "UNIQUE",
            markdown: "_unique_"
          },
          where: {
            default: "WHERE",
            markdown: "_where_"
          },
          using: {
            default: "USING",
            markdown: "_using_"
          }
        }.freeze

        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          index_info = if @options[:format_markdown]
            "#\n# ### Indexes\n#\n"
          else
            "#\n# Indexes\n#\n"
          end

          indexes = @model.retrieve_indexes_from_table
          return "" if indexes.empty?

          max_size = indexes.collect { |index| index.name.size }.max + 1
          indexes.sort_by(&:name).each do |index|
            index_info += if @options[:format_markdown]
              final_index_string_in_markdown(index)
            else
              final_index_string(index, max_size)
            end
          end

          index_info
        end

        private

        def index_using_info(index, format = :default)
          value = index.try(:using) && index.using.try(:to_sym)
          if !value.blank? && value != :btree
            " #{INDEX_CLAUSES[:using][format]} #{value}"
          else
            ""
          end
        end

        def index_where_info(index, format = :default)
          value = index.try(:where).try(:to_s)
          if value.blank?
            ""
          else
            " #{INDEX_CLAUSES[:where][format]} #{value}"
          end
        end

        def index_unique_info(index, format = :default)
          index.unique ? " #{INDEX_CLAUSES[:unique][format]}" : ""
        end

        def final_index_string_in_markdown(index)
          details = format(
            "%s%s%s",
            index_unique_info(index, :markdown),
            index_where_info(index, :markdown),
            index_using_info(index, :markdown)
          ).strip
          details = " (#{details})" unless details.blank?

          format(
            "# * `%s`%s:\n#     * **`%s`**\n",
            index.name,
            details,
            index_columns_info(index).join("`**\n#     * **`")
          )
        end

        def final_index_string(index, max_size)
          format(
            "#  %-#{max_size}.#{max_size}s %s%s%s%s",
            index.name,
            "(#{index_columns_info(index).join(",")})",
            index_unique_info(index),
            index_where_info(index),
            index_using_info(index)
          ).rstrip + "\n"
        end

        def index_columns_info(index)
          Array(index.columns).map do |col|
            if index.try(:orders) && index.orders[col.to_s]
              "#{col} #{index.orders[col.to_s].upcase}"
            else
              col.to_s.gsub("\r", '\r').gsub("\n", '\n')
            end
          end
        end
      end
    end
  end
end
