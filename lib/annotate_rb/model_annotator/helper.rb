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

        def non_ascii_length(string)
          string.to_s.chars.reject(&:ascii_only?).length
        end

        def wrapped_content(content, options)
          if options[:wrapper_open]
            wrapper_open = "# #{options[:wrapper_open]}\n"
          else
            wrapper_open = ""
          end

          if options[:wrapper_close]
            wrapper_close = "# #{options[:wrapper_close]}\n"
          else
            wrapper_close = ""
          end

          _wrapped_info_block = "#{wrapper_open}#{content}#{wrapper_close}"
        end

        def width(string)
          string.chars.inject(0) { |acc, elem| acc + (elem.bytesize == 3 ? 2 : 1) }
        end

        # TODO: Find another implementation that doesn't depend on ActiveSupport
        def fallback(*args)
          args.compact.detect(&:present?)
        end
      end
    end
  end
end
