# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class ModelWrapper
      # Should be the wrapper for an ActiveRecord model that serves as the source of truth of the model
      # of the model that we're annotating

      def initialize(klass, options = {})
        @klass = klass
        @options = options
      end

      # Gets the columns of the ActiveRecord model, processes them, and then returns them.
      def columns
        @columns ||= begin
                       cols = raw_columns
                       cols += translated_columns

                       ignore_columns = @options[:ignore_columns]
                       if ignore_columns
                         cols = cols.reject do |col|
                           col.name.match(/#{ignore_columns}/)
                         end
                       end

                       cols = cols.sort_by(&:name) if @options[:sort]
                       cols = classified_sort(cols) if @options[:classified_sort]

                       cols
                     end
      end

      def connection
        @klass.connection
      end

      # Returns the unmodified model columns
      def raw_columns
        @raw_columns ||= @klass.columns
      end

      def primary_key
        @klass.primary_key
      end

      def table_exists?
        @klass.table_exists?
      end

      def column_defaults
        @klass.column_defaults
      end

      # Add columns managed by the globalize gem if this gem is being used.
      # TODO: Audit if this is still needed, it seems like Globalize gem is no longer maintained
      def translated_columns
        return [] unless @klass.respond_to?(:translation_class)

        ignored_cols = ignored_translation_table_columns

        @klass.translation_class.columns.reject do |col|
          ignored_cols.include? col.name.to_sym
        end
      end

      def table_name
        @klass.table_name
      end

      def model_name
        @klass.name.underscore
      end

      # Calculates the max width of the schema for the model by looking at the columns, schema comments, with respect
      # to the options.
      def max_schema_info_width
        cols = columns

        if with_comments?
          max_size = cols.map do |column|
            column.name.size + (column.comment ? Helper.width(column.comment) : 0)
          end.max || 0
          max_size += 2
        else
          max_size = cols.map(&:name).map(&:size).max
        end
        max_size += @options[:format_rdoc] ? 5 : 1

        max_size
      end

      def retrieve_indexes_from_table
        table_name = @klass.table_name
        return [] unless table_name

        indexes = @klass.connection.indexes(table_name)
        return indexes if indexes.any? || !@klass.table_name_prefix

        # Try to search the table without prefix
        table_name_without_prefix = table_name.to_s.sub(@klass.table_name_prefix, '')
        @klass.connection.indexes(table_name_without_prefix)
      end

      def with_comments?
        @options[:with_comment] &&
          raw_columns.first.respond_to?(:comment) &&
          raw_columns.map(&:comment).any? { |comment| !comment.nil? }
      end

      def classified_sort(cols)
        rest_cols = []
        timestamps = []
        associations = []
        id = nil

        cols.each do |c|
          if c.name.eql?('id')
            id = c
          elsif c.name.eql?('created_at') || c.name.eql?('updated_at')
            timestamps << c
          elsif c.name[-3, 3].eql?('_id')
            associations << c
          else
            rest_cols << c
          end
        end
        [rest_cols, timestamps, associations].each { |a| a.sort_by!(&:name) }

        ([id] << rest_cols << timestamps << associations).flatten.compact
      end

      # These are the columns that the globalize gem needs to work but
      # are not necessary for the models to be displayed as annotations.
      def ignored_translation_table_columns
        # Construct the foreign column name in the translations table
        # eg. Model: Car, foreign column name: car_id
        foreign_column_name = [
          @klass.translation_class.to_s
               .gsub('::Translation', '').gsub('::', '_')
               .downcase,
          '_id'
        ].join.to_sym

        [
          :id,
          :created_at,
          :updated_at,
          :locale,
          foreign_column_name
        ]
      end
    end
  end
end