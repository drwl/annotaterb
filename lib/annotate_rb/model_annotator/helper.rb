# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Helper
      INDEX_CLAUSES = {
        unique: {
          default: 'UNIQUE',
          markdown: '_unique_'
        },
        where: {
          default: 'WHERE',
          markdown: '_where_'
        },
        using: {
          default: 'USING',
          markdown: '_using_'
        }
      }.freeze

      class << self
        def mb_chars_ljust(string, length)
          string = string.to_s
          padding = length - Helper.width(string)
          if padding.positive?
            string + (' ' * padding)
          else
            string[0..(length - 1)]
          end
        end

        def index_unique_info(index, format = :default)
          index.unique ? " #{INDEX_CLAUSES[:unique][format]}" : ''
        end

        def index_where_info(index, format = :default)
          value = index.try(:where).try(:to_s)
          if value.blank?
            ''
          else
            " #{INDEX_CLAUSES[:where][format]} #{value}"
          end
        end

        def index_using_info(index, format = :default)
          value = index.try(:using) && index.using.try(:to_sym)
          if !value.blank? && value != :btree
            " #{INDEX_CLAUSES[:using][format]} #{value}"
          else
            ''
          end
        end

        def map_col_type_to_ruby_classes(col_type)
          case col_type
          when 'integer' then Integer.to_s
          when 'float' then Float.to_s
          when 'decimal' then BigDecimal.to_s
          when 'datetime', 'timestamp', 'time' then Time.to_s
          when 'date' then Date.to_s
          when 'text', 'string', 'binary', 'inet', 'uuid' then String.to_s
          when 'json', 'jsonb' then Hash.to_s
          when 'boolean' then 'Boolean'
          end
        end

        def non_ascii_length(string)
          string.to_s.chars.reject(&:ascii_only?).length
        end

        # Simple quoting for the default column value
        def quote(value)
          case value
          when NilClass then 'NULL'
          when TrueClass then 'TRUE'
          when FalseClass then 'FALSE'
          when Float, Integer then value.to_s
          # BigDecimals need to be output in a non-normalized form and quoted.
          when BigDecimal then value.to_s('F')
          when Array then value.map { |v| quote(v) }
          else
            value.inspect
          end
        end

        def width(string)
          string.chars.inject(0) { |acc, elem| acc + (elem.bytesize == 3 ? 2 : 1) }
        end

        def magic_comments_as_string(content)
          magic_comments = content.scan(Annotator::MAGIC_COMMENT_MATCHER).flatten.compact

          if magic_comments.any?
            magic_comments.join
          else
            ''
          end
        end

        # TODO: Find another implementation that doesn't depend on ActiveSupport
        def fallback(*args)
          args.compact.detect(&:present?)
        end
      end
    end
  end
end
