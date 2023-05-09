module AnnotateRb
  module ModelAnnotator
    class AnnotationGenerator
      # Annotate Models plugin use this header
      PREFIX = '== Schema Information'.freeze
      PREFIX_MD = '## Schema Information'.freeze

      END_MARK = '== Schema Information End'.freeze

      MD_NAMES_OVERHEAD = 6
      MD_TYPE_ALLOWANCE = 18

      def initialize(klass, header, options)
        @klass = klass
        @header = header
        @options = options
        @model_thing = ModelThing.new(klass, options)
        @info = "" # TODO: Make array and build string that way
      end

      def generate
        @info = "# #{header}\n"
        @info += schema_header_text

        max_size = @model_thing.max_schema_info_width

        if @options[:format_markdown]
          @info += format("# %-#{max_size + MD_NAMES_OVERHEAD}.#{max_size + MD_NAMES_OVERHEAD}s | %-#{MD_TYPE_ALLOWANCE}.#{MD_TYPE_ALLOWANCE}s | %s\n",
                          'Name',
                          'Type',
                          'Attributes')
          @info += "# #{'-' * (max_size + MD_NAMES_OVERHEAD)} | #{'-' * MD_TYPE_ALLOWANCE} | #{'-' * 27}\n"
        end

        add_column_info(max_size)

        if @options[:show_indexes] && @klass.table_exists?
          @info += IndexAnnotationBuilder.new(@model_thing, @options).build
        end

        if @options[:show_foreign_keys] && @klass.table_exists?
          @info += foreign_key_info
        end

        @info += schema_footer_text

        @info
      end

      def add_column_info(max_size)
        cols = @model_thing.columns

        @info += cols.map do |col|
          ColumnAnnotationBuilder.new(col, @model_thing, max_size, @options).build
        end.join

        @info
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
    end
  end
end