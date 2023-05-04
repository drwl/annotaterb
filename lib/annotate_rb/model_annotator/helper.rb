# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    module Helper
      MATCHED_TYPES = %w(test fixture factory serializer scaffold controller helper).freeze

      class << self
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
