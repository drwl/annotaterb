# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module IndexAnnotation
      class AnnotationBuilder
        Index = Struct.new(:index, :max_size) do
          def to_default
            unique_info = index.unique ? " UNIQUE" : ""

            value = index.try(:where).try(:to_s)
            where_info = if value.blank?
              ""
            else
              " WHERE #{value}"
            end

            value = index.try(:using) && index.using.try(:to_sym)
            using_info = if !value.blank? && value != :btree
              " USING #{value}"
            else
              ""
            end

            format(
              "#  %-#{max_size}.#{max_size}s %s%s%s%s",
              index.name,
              "(#{index_columns_info(index).join(",")})",
              unique_info,
              where_info,
              using_info
            ).rstrip
          end

          def to_markdown
            unique_info = index.unique ? " _unique_" : ""

            value = index.try(:where).try(:to_s)
            where_info = if value.blank?
              ""
            else
              " _where_ #{value}"
            end

            value = index.try(:using) && index.using.try(:to_sym)
            using_info = if !value.blank? && value != :btree
              " _using_ #{value}"
            else
              ""
            end

            details = format(
              "%s%s%s",
              unique_info,
              where_info,
              using_info
            ).strip
            details = " (#{details})" unless details.blank?

            format(
              "# * `%s`%s:\n#     * **`%s`**",
              index.name,
              details,
              index_columns_info(index).join("`**\n#     * **`")
            )
          end

          private

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

        class Annotation
          HEADER_TEXT = "Indexes"

          def initialize(indexes)
            @indexes = indexes
          end

          def body
            [
              Components::BlankLine.new,
              Components::Header.new(HEADER_TEXT),
              Components::BlankLine.new,
              *@indexes,
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

        def initialize(model, options)
          @model = model
          @options = options
        end

        def build
          indexes = @model.retrieve_indexes_from_table
          return "" if indexes.empty?

          max_size = indexes.map { |index| index.name.size }.max + 1

          indexes = indexes.sort_by(&:name).map do |index|
            Index.new(index, max_size)
          end

          if @options[:format_markdown]
            Annotation.new(indexes).to_markdown
          else
            Annotation.new(indexes).to_default
          end
        end
      end
    end
  end
end
