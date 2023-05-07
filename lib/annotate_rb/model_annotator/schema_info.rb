module AnnotateRb
  module ModelAnnotator
    module SchemaInfo # rubocop:disable Metrics/ModuleLength
      # Don't show default value for these column types
      NO_DEFAULT_COL_TYPES = %w[json jsonb hstore].freeze

      # Don't show limit (#) on these column types
      # Example: show "integer" instead of "integer(4)"
      NO_LIMIT_COL_TYPES = %w[integer bigint boolean].freeze

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

      END_MARK = '== Schema Information End'.freeze

      class << self
        # Use the column information in an ActiveRecord class
        # to create a comment block containing a line for
        # each column. The line contains the column name,
        # the type (and length), and any optional attributes
        def generate(klass, header, options = {}) # rubocop:disable Metrics/MethodLength
          model_thing = ModelThing.new(klass, options)

          info = "# #{header}\n"
          info << model_thing.get_schema_header_text

          max_size = model_thing.max_schema_info_width
          md_names_overhead = 6
          md_type_allowance = 18
          bare_type_allowance = 16

          if options[:format_markdown]
            info << format("# %-#{max_size + md_names_overhead}.#{max_size + md_names_overhead}s | %-#{md_type_allowance}.#{md_type_allowance}s | %s\n",
                           'Name',
                           'Type',
                           'Attributes')
            info << "# #{'-' * (max_size + md_names_overhead)} | #{'-' * md_type_allowance} | #{'-' * 27}\n"
          end

          cols = model_thing.columns
          cols.each do |col|
            col_type = get_col_type(col)
            attrs = get_attributes(col, col_type, klass, options)
            col_name = if with_comments?(klass, options) && col.comment
                         "#{col.name}(#{col.comment.gsub(/\n/, '\\n')})"
                       else
                         col.name
                       end

            if options[:format_rdoc]
              info << format("# %-#{max_size}.#{max_size}s<tt>%s</tt>",
                             "*#{col_name}*::",
                             attrs.unshift(col_type).join(', ')).rstrip + "\n"
            elsif options[:format_yard]
              info << sprintf("# @!attribute #{col_name}") + "\n"
              ruby_class = col.respond_to?(:array) && col.array ? "Array<#{Helper.map_col_type_to_ruby_classes(col_type)}>" : Helper.map_col_type_to_ruby_classes(col_type)
              info << sprintf("#   @return [#{ruby_class}]") + "\n"
            elsif options[:format_markdown]
              name_remainder = max_size - col_name.length - non_ascii_length(col_name)
              type_remainder = (md_type_allowance - 2) - col_type.length
              info << format("# **`%s`**%#{name_remainder}s | `%s`%#{type_remainder}s | `%s`",
                             col_name,
                             ' ',
                             col_type,
                             ' ',
                             attrs.join(', ').rstrip).gsub('``', '  ').rstrip + "\n"
            else
              info << format_default(col_name, max_size, col_type, bare_type_allowance, attrs)
            end
          end

          info << get_index_info(klass, options) if options[:show_indexes] && klass.table_exists?

          info << get_foreign_key_info(klass, options) if options[:show_foreign_keys] && klass.table_exists?

          info << get_schema_footer_text(klass, options)
        end

        private

        def with_comments?(klass, options)
          model_thing = ModelThing.new(klass, options)

          options[:with_comment] &&
            model_thing.raw_columns.first.respond_to?(:comment) &&
            model_thing.raw_columns.map(&:comment).any? { |comment| !comment.nil? }
        end

        def get_col_type(col)
          if (col.respond_to?(:bigint?) && col.bigint?) || /\Abigint\b/ =~ col.sql_type
            'bigint'
          else
            (col.type || col.sql_type).to_s
          end
        end

        # Get the list of attributes that should be included in the annotation for
        # a given column.
        def get_attributes(column, column_type, klass, options)
          attrs = []
          attrs << "default(#{schema_default(klass, column)})" unless column.default.nil? || hide_default?(column_type, options)
          attrs << 'unsigned' if column.respond_to?(:unsigned?) && column.unsigned?
          attrs << 'not null' unless column.null
          attrs << 'primary key' if klass.primary_key && (klass.primary_key.is_a?(Array) ? klass.primary_key.collect(&:to_sym).include?(column.name.to_sym) : column.name.to_sym == klass.primary_key.to_sym)

          if column_type == 'decimal'
            column_type << "(#{column.precision}, #{column.scale})"
          elsif !%w[spatial geometry geography].include?(column_type)
            if column.limit && !options[:format_yard]
              if column.limit.is_a? Array
                attrs << "(#{column.limit.join(', ')})"
              else
                column_type << "(#{column.limit})" unless hide_limit?(column_type, options)
              end
            end
          end

          # Check out if we got an array column
          attrs << 'is an Array' if column.respond_to?(:array) && column.array

          # Check out if we got a geometric column
          # and print the type and SRID
          if column.respond_to?(:geometry_type)
            attrs << "#{column.geometry_type}, #{column.srid}"
          elsif column.respond_to?(:geometric_type) && column.geometric_type.present?
            attrs << "#{column.geometric_type.to_s.downcase}, #{column.srid}"
          end

          # Check if the column has indices and print "indexed" if true
          # If the index includes another column, print it too.
          if options[:simple_indexes] && klass.table_exists? # Check out if this column is indexed
            indices = retrieve_indexes_from_table(klass).select { |ind| ind.columns.include? column.name }
            indices&.sort_by(&:name)&.each do |ind|
              next if ind.columns.is_a?(String)

              ind = ind.columns.reject! { |i| i == column.name }
              attrs << (ind.empty? ? 'indexed' : "indexed => [#{ind.join(', ')}]")
            end
          end

          attrs
        end

        def schema_default(klass, column)
          Helper.quote(klass.column_defaults[column.name])
        end

        def hide_default?(col_type, options)
          excludes =
            if options[:hide_default_column_types].blank?
              NO_DEFAULT_COL_TYPES
            else
              options[:hide_default_column_types].split(',')
            end

          excludes.include?(col_type)
        end

        def hide_limit?(col_type, options)
          excludes =
            if options[:hide_limit_column_types].blank?
              NO_LIMIT_COL_TYPES
            else
              options[:hide_limit_column_types].split(',')
            end

          excludes.include?(col_type)
        end

        def retrieve_indexes_from_table(klass)
          table_name = klass.table_name
          return [] unless table_name

          indexes = klass.connection.indexes(table_name)
          return indexes if indexes.any? || !klass.table_name_prefix

          # Try to search the table without prefix
          table_name_without_prefix = table_name.to_s.sub(klass.table_name_prefix, '')
          klass.connection.indexes(table_name_without_prefix)
        end

        def non_ascii_length(string)
          string.to_s.chars.reject(&:ascii_only?).length
        end

        def format_default(col_name, max_size, col_type, bare_type_allowance, attrs)
          format('#  %s:%s %s',
                 mb_chars_ljust(col_name, max_size),
                 mb_chars_ljust(col_type, bare_type_allowance),
                 attrs.join(', ')).rstrip + "\n"
        end

        def mb_chars_ljust(string, length)
          string = string.to_s
          padding = length - Helper.width(string)
          if padding.positive?
            string + (' ' * padding)
          else
            string[0..(length - 1)]
          end
        end

        def get_index_info(klass, options = {})
          index_info = if options[:format_markdown]
                         "#\n# ### Indexes\n#\n"
                       else
                         "#\n# Indexes\n#\n"
                       end

          indexes = retrieve_indexes_from_table(klass)
          return '' if indexes.empty?

          max_size = indexes.collect { |index| index.name.size }.max + 1
          indexes.sort_by(&:name).each do |index|
            index_info << if options[:format_markdown]
                            final_index_string_in_markdown(index)
                          else
                            final_index_string(index, max_size)
                          end
          end

          index_info
        end

        def final_index_string_in_markdown(index)
          details = format(
            '%s%s%s',
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
            "(#{index_columns_info(index).join(',')})",
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

        def index_where_info(index, format = :default)
          value = index.try(:where).try(:to_s)
          if value.blank?
            ''
          else
            " #{INDEX_CLAUSES[:where][format]} #{value}"
          end
        end

        def index_unique_info(index, format = :default)
          index.unique ? " #{INDEX_CLAUSES[:unique][format]}" : ''
        end

        def index_using_info(index, format = :default)
          value = index.try(:using) && index.using.try(:to_sym)
          if !value.blank? && value != :btree
            " #{INDEX_CLAUSES[:using][format]} #{value}"
          else
            ''
          end
        end

        def get_foreign_key_info(klass, options = {})
          fk_info = if options[:format_markdown]
                      "#\n# ### Foreign Keys\n#\n"
                    else
                      "#\n# Foreign Keys\n#\n"
                    end

          return '' unless klass.connection.respond_to?(:supports_foreign_keys?) &&
            klass.connection.supports_foreign_keys? && klass.connection.respond_to?(:foreign_keys)

          foreign_keys = klass.connection.foreign_keys(klass.table_name)
          return '' if foreign_keys.empty?

          format_name = lambda do |fk|
            return fk.options[:column] if fk.name.blank?

            options[:show_complete_foreign_keys] ? fk.name : fk.name.gsub(/(?<=^fk_rails_)[0-9a-f]{10}$/, '...')
          end

          max_size = foreign_keys.map(&format_name).map(&:size).max + 1
          foreign_keys.sort_by { |fk| [format_name.call(fk), fk.column] }.each do |fk|
            ref_info = "#{fk.column} => #{fk.to_table}.#{fk.primary_key}"
            constraints_info = ''
            constraints_info += "ON DELETE => #{fk.on_delete} " if fk.on_delete
            constraints_info += "ON UPDATE => #{fk.on_update} " if fk.on_update
            constraints_info.strip!

            fk_info << if options[:format_markdown]
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

        def get_schema_footer_text(_klass, options = {})
          info = ''
          if options[:format_rdoc]
            info << "#--\n"
            info << "# #{END_MARK}\n"
            info << "#++\n"
          else
            info << "#\n"
          end
        end
      end
    end
  end
end
