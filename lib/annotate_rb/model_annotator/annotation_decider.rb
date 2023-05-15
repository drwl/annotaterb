# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    # Class that encapsulates the logic to decide whether to annotate a model file and its related files or not.
    class AnnotationDecider
      def initialize(file, options)
        @file = file
        @options = options
      end

      def annotate?
        return false if file_contains_skip_annotation

        begin
          klass = ModelClassGetter.call(@file, @options)

          klass_is_a_class = klass.is_a?(Class)
          klass_inherits_active_record_base = klass < ActiveRecord::Base
          klass_is_not_abstract = klass.respond_to?(:abstract_class) && !klass.abstract_class?
          klass_table_exists = klass.respond_to?(:abstract_class) && klass.table_exists?

          not_sure_this_conditional = (!@options[:exclude_sti_subclasses] || !(klass.superclass < ActiveRecord::Base && klass.table_name == klass.superclass.table_name))

          annotate_conditions = [
            klass_is_a_class,
            klass_inherits_active_record_base,
            not_sure_this_conditional,
            klass_is_not_abstract,
            klass_table_exists
          ]

          to_annotate = annotate_conditions.all?

          return to_annotate
        rescue BadModelFileError => e
          unless @options[:ignore_unknown_models]
            $stderr.puts "Unable to annotate #{@file}: #{e.message}"
            $stderr.puts "\t" + e.backtrace.join("\n\t") if @options[:trace]
          end
        rescue StandardError => e
          $stderr.puts "Unable to annotate #{@file}: #{e.message}"
          $stderr.puts "\t" + e.backtrace.join("\n\t") if @options[:trace]
        end

        false
      end

      private

      def file_contains_skip_annotation
        file_string = File.exist?(@file) ? File.read(@file) : ''

        if /#{Constants::SKIP_ANNOTATION_PREFIX}.*/ =~ file_string
          true
        else
          false
        end
      end
    end
  end
end