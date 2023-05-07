module AnnotateRb
  module ModelAnnotator
    module SchemaInfo # rubocop:disable Metrics/ModuleLength
      class << self
        # Use the column information in an ActiveRecord class
        # to create a comment block containing a line for
        # each column. The line contains the column name,
        # the type (and length), and any optional attributes
        def generate(klass, header, options = {})
          # rubocop:disable Metrics/MethodLength
          model_thing = ModelThing.new(klass, options)
          generator = AnnotationGenerator.new(klass, header, options)

          info = "# #{generator.header}\n"
          info << generator.schema_header_text

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
            col_type = Helper.get_col_type(col)
            # `col_type` gets modified in `get_attributes`. Need to change method so it does not mutate input.
            attrs = get_attributes(col, col_type, klass, options)
            col_name = if model_thing.with_comments? && col.comment
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

              if col.respond_to?(:array) && col.array
                ruby_class = "Array<#{Helper.map_col_type_to_ruby_classes(col_type)}>"
              else
                ruby_class = Helper.map_col_type_to_ruby_classes(col_type)
              end

              info << sprintf("#   @return [#{ruby_class}]") + "\n"
            elsif options[:format_markdown]
              name_remainder = max_size - col_name.length - Helper.non_ascii_length(col_name)
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

          if options[:show_indexes] && klass.table_exists?
            info << get_index_info(klass, options)
          end

          if options[:show_foreign_keys] && klass.table_exists?
            info << get_foreign_key_info(klass, options)
          end

          info << generator.schema_footer_text
        end

        private

        # Get the list of attributes that should be included in the annotation for
        # a given column.
        def get_attributes(column, column_type, klass, options)
          attrs = []

          model_thing = ModelThing.new(klass, options)
          column_thing = ColumnThing.new(column, options)

          unless column_thing.default.nil? || column_thing.hide_default?
            attrs << "default(#{schema_default(klass, column_thing)})"
          end

          if column_thing.unsigned?
            attrs << 'unsigned'
          end

          if !column_thing.null
            attrs << 'not null'
          end

          if klass.primary_key
            if klass.primary_key.is_a?(Array)
              if klass.primary_key.collect(&:to_sym).include?(column_thing.name.to_sym)
                attrs << 'primary key'
              end
            else
              if column_thing.name.to_sym == klass.primary_key.to_sym
                attrs << 'primary key'
              end
            end
          end

          if column_thing.column_type == 'decimal'
            column_type << "(#{column_thing.precision}, #{column_thing.scale})"
          elsif !%w[spatial geometry geography].include?(column_thing.column_type)
            if column_thing.limit && !options[:format_yard]
              if column_thing.limit.is_a? Array
                attrs << "(#{column_thing.limit.join(', ')})"
              else
                unless column_thing.hide_limit?
                  column_type << "(#{column_thing.limit})"
                end
              end
            end
          end

          # Check out if we got an array column
          if column_thing.array?
            attrs << 'is an Array'
          end

          # Check out if we got a geometric column
          # and print the type and SRID
          if column_thing.geometry_type?
            attrs << "#{column_thing.geometry_type}, #{column_thing.srid}"
          elsif column_thing.geometric_type? && column_thing.geometric_type.present?
            attrs << "#{column_thing.geometric_type.to_s.downcase}, #{column_thing.srid}"
          end

          # Check if the column has indices and print "indexed" if true
          # If the index includes another column, print it too.
          if options[:simple_indexes] && klass.table_exists? # Check out if this column is indexed
            table_indices = model_thing.retrieve_indexes_from_table
            indices = table_indices.select { |ind| ind.columns.include? column_thing.name }
            indices&.sort_by(&:name)&.each do |ind|
              next if ind.columns.is_a?(String)

              ind = ind.columns.reject! { |i| i == column_thing.name }
              attrs << (ind.empty? ? 'indexed' : "indexed => [#{ind.join(', ')}]")
            end
          end

          attrs
        end

        def schema_default(klass, column)
          Helper.quote(klass.column_defaults[column.name])
        end

        def format_default(col_name, max_size, col_type, bare_type_allowance, attrs)
          format('#  %s:%s %s',
                 Helper.mb_chars_ljust(col_name, max_size),
                 Helper.mb_chars_ljust(col_type, bare_type_allowance),
                 attrs.join(', ')).rstrip + "\n"
        end

        def get_index_info(klass, options = {})
          index_info = if options[:format_markdown]
                         "#\n# ### Indexes\n#\n"
                       else
                         "#\n# Indexes\n#\n"
                       end

          model_thing = ModelThing.new(klass, options)

          indexes = model_thing.retrieve_indexes_from_table
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
      end
    end
  end
end
