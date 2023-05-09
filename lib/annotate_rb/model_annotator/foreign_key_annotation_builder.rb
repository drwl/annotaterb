# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ForeignKeyAnnotationBuilder
      def initialize(klass, options)
        @klass = klass
        @options = options
      end

      def build
        fk_info = if @options[:format_markdown]
                    "#\n# ### Foreign Keys\n#\n"
                  else
                    "#\n# Foreign Keys\n#\n"
                  end

        return '' unless @klass.connection.respond_to?(:supports_foreign_keys?) &&
          @klass.connection.supports_foreign_keys? && @klass.connection.respond_to?(:foreign_keys)

        foreign_keys = @klass.connection.foreign_keys(@klass.table_name)
        return '' if foreign_keys.empty?

        format_name = lambda do |fk|
          return fk.options[:column] if fk.name.blank?

          @options[:show_complete_foreign_keys] ? fk.name : fk.name.gsub(/(?<=^fk_rails_)[0-9a-f]{10}$/, '...')
        end

        max_size = foreign_keys.map(&format_name).map(&:size).max + 1
        foreign_keys.sort_by { |fk| [format_name.call(fk), fk.column] }.each do |fk|
          ref_info = "#{fk.column} => #{fk.to_table}.#{fk.primary_key}"
          constraints_info = ''
          constraints_info += "ON DELETE => #{fk.on_delete} " if fk.on_delete
          constraints_info += "ON UPDATE => #{fk.on_update} " if fk.on_update
          constraints_info = constraints_info.strip

          fk_info += if @options[:format_markdown]
                       format("# * `%s`%s:\n#     * **`%s`**\n",
                              format_name.call(fk),
                              constraints_info.blank? ? '' : " (_#{constraints_info}_)",
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
    end
  end
end