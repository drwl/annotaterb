module AnnotateRb
  module ModelAnnotator
    class AnnotationGenerator
      # Annotate Models plugin use this header
      PREFIX = '== Schema Information'.freeze
      PREFIX_MD = '## Schema Information'.freeze

      END_MARK = '== Schema Information End'.freeze

      MD_NAMES_OVERHEAD = 6
      MD_TYPE_ALLOWANCE = 18
      BARE_TYPE_ALLOWANCE = 16

      def initialize(klass, header, options)
        @klass = klass
        @header = header
        @options = options
        @model_thing = ModelThing.new(klass, options)
        @info = "" # TODO: Make array and build string that way
      end

      def generate
        @info = "# #{header}\n"
        @info << schema_header_text

        max_size = @model_thing.max_schema_info_width

        if @options[:format_markdown]
          @info << format("# %-#{max_size + MD_NAMES_OVERHEAD}.#{max_size + MD_NAMES_OVERHEAD}s | %-#{MD_TYPE_ALLOWANCE}.#{MD_TYPE_ALLOWANCE}s | %s\n",
                         'Name',
                         'Type',
                         'Attributes')
          @info << "# #{'-' * (max_size + MD_NAMES_OVERHEAD)} | #{'-' * MD_TYPE_ALLOWANCE} | #{'-' * 27}\n"
        end

        add_column_info(max_size)

        if @options[:show_indexes] && @klass.table_exists?
          @info << index_info
        end

        if @options[:show_foreign_keys] && @klass.table_exists?
          @info << foreign_key_info
        end

        @info << schema_footer_text

        @info
      end

      def add_column_info(max_size)
        cols = @model_thing.columns
        cols.each do |col|
          column_thing = ColumnThing.new(col, @klass, @options)

          col_type = column_thing.column_type
          # `col_type` gets modified in `get_attributes`. Need to change method so it does not mutate input.
          attrs = column_thing.get_attributes(col_type)
          col_name = if @model_thing.with_comments? && col.comment
                       "#{col.name}(#{col.comment.gsub(/\n/, '\\n')})"
                     else
                       col.name
                     end

          if @options[:format_rdoc]
            @info << format("# %-#{max_size}.#{max_size}s<tt>%s</tt>",
                            "*#{col_name}*::",
                            attrs.unshift(col_type).join(', ')).rstrip + "\n"
          elsif @options[:format_yard]
            @info << sprintf("# @!attribute #{col_name}") + "\n"

            if col.respond_to?(:array) && col.array
              ruby_class = "Array<#{Helper.map_col_type_to_ruby_classes(col_type)}>"
            else
              ruby_class = Helper.map_col_type_to_ruby_classes(col_type)
            end

            @info << sprintf("#   @return [#{ruby_class}]") + "\n"
          elsif @options[:format_markdown]
            name_remainder = max_size - col_name.length - Helper.non_ascii_length(col_name)
            type_remainder = (MD_TYPE_ALLOWANCE - 2) - col_type.length
            @info << format("# **`%s`**%#{name_remainder}s | `%s`%#{type_remainder}s | `%s`",
                            col_name,
                            ' ',
                            col_type,
                            ' ',
                            attrs.join(', ').rstrip).gsub('``', '  ').rstrip + "\n"
          else
            @info << format_default(col_name, max_size, col_type, attrs)
          end
        end
      end

      def index_info
        index_info = if @options[:format_markdown]
                       "#\n# ### Indexes\n#\n"
                     else
                       "#\n# Indexes\n#\n"
                     end

        indexes = @model_thing.retrieve_indexes_from_table
        return '' if indexes.empty?

        max_size = indexes.collect { |index| index.name.size }.max + 1
        indexes.sort_by(&:name).each do |index|
          index_info << if @options[:format_markdown]
                          final_index_string_in_markdown(index)
                        else
                          final_index_string(index, max_size)
                        end
        end

        index_info
      end

      # TODO: Move header logic into here from AnnotateRb::ModelAnnotator::Annotator.do_annotations
      def header
        @header
      end

      def schema_header_text
        info = []
        info << "#"

        if @options[:format_markdown]
          info << "# Table name: `#{@model_thing.table_name}`"
          info << "#"
          info << "# ### Columns"
        else
          info << "# Table name: #{@model_thing.table_name}"
        end
        info << "#\n" # We want the last line break

        info.join("\n")
      end

      def schema_footer_text
        info = ''
        if @options[:format_rdoc]
          info << "#--\n"
          info << "# #{END_MARK}\n"
          info << "#++\n"
        else
          info << "#\n"
        end
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

      def foreign_key_info
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
          constraints_info.strip!

          fk_info << if @options[:format_markdown]
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

      def format_default(col_name, max_size, col_type, attrs)
        format('#  %s:%s %s',
               Helper.mb_chars_ljust(col_name, max_size),
               Helper.mb_chars_ljust(col_type, BARE_TYPE_ALLOWANCE),
               attrs.join(', ')).rstrip + "\n"
      end
    end
  end
end