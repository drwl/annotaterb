# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Helper
      MATCHED_TYPES = %w(test fixture factory serializer scaffold controller helper).freeze

      class << self
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

        def matched_types(options)
          types = MATCHED_TYPES.dup
          types << 'admin' if options[:active_admin] =~ Constants::TRUE_RE && !types.include?('admin')
          types << 'additional_file_patterns' if options[:additional_file_patterns].present?

          types
        end

        def magic_comments_as_string(content)
          magic_comments = content.scan(Annotator::MAGIC_COMMENT_MATCHER).flatten.compact

          if magic_comments.any?
            magic_comments.join
          else
            ''
          end
        end

        def true?(val)
          val.present? && Constants::TRUE_RE.match?(val)
        end

        # TODO: Find another implementation that doesn't depend on ActiveSupport
        def fallback(*args)
          args.compact.detect(&:present?)
        end
      end
    end
  end
end
