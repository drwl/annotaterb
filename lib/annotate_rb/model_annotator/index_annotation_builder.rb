# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class IndexAnnotationBuilder
      def initialize(model_thing, options)
        @model_thing = model_thing
        @options = options
      end

      def build
        index_info = if @options[:format_markdown]
                       "#\n# ### Indexes\n#\n"
                     else
                       "#\n# Indexes\n#\n"
                     end

        indexes = @model_thing.retrieve_indexes_from_table
        return '' if indexes.empty?

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

      def final_index_string_in_markdown(index)
        details = format(
          '%s%s%s',
          Helper.index_unique_info(index, :markdown),
          Helper.index_where_info(index, :markdown),
          Helper.index_using_info(index, :markdown)
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
          "(#{index_columns_info(index).join(',')})",
          Helper.index_unique_info(index),
          Helper.index_where_info(index),
          Helper.index_using_info(index)
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
