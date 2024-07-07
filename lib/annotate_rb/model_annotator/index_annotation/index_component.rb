# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module IndexAnnotation
      class IndexComponent < Components::Base
        attr_reader :index, :max_size

        def initialize(index, max_size)
          @index = index
          @max_size = max_size
        end

        def to_default
          unique_info = index.unique ? " UNIQUE" : ""

          value = index.try(:where).try(:to_s)
          where_info = if value.present?
            " WHERE #{value}"
          else
            ""
          end

          value = index.try(:using).try(:to_sym)
          using_info = if value.present? && value != :btree
            " USING #{value}"
          else
            ""
          end

          # standard:disable Lint/FormatParameterMismatch
          sprintf(
            "#  %-#{max_size}.#{max_size}s %s%s%s%s",
            index.name,
            "(#{columns_info.join(",")})",
            unique_info,
            where_info,
            using_info
          ).rstrip
          # standard:enable Lint/FormatParameterMismatch
        end

        def to_markdown
          unique_info = index.unique ? " _unique_" : ""

          value = index.try(:where).try(:to_s)
          where_info = if value.present?
            " _where_ #{value}"
          else
            ""
          end

          value = index.try(:using).try(:to_sym)
          using_info = if value.present? && value != :btree
            " _using_ #{value}"
          else
            ""
          end

          details = sprintf(
            "%s%s%s",
            unique_info,
            where_info,
            using_info
          ).strip
          details = " (#{details})" unless details.blank?

          sprintf(
            "# * `%s`%s:\n#     * **`%s`**",
            index.name,
            details,
            columns_info.join("`**\n#     * **`")
          )
        end

        private

        def columns_info
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
