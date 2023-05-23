# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class Annotator
      class << self
        def do_annotations(options = {})
          new(options).do_annotations
        end

        def remove_annotations(options = {})
          new(options).remove_annotations
        end
      end

      def initialize(options)
        @options = options
      end

      def do_annotations
        ProjectAnnotator.new(@options).annotate
      end

      def remove_annotations
        unannotated = []

        model_files_to_consider = ModelFilesGetter.call(@options)

        model_files_to_consider.each do |path, filename|
          unannotated_klass = false
          file = File.join(path, filename)

          begin
            klass = ModelClassGetter.call(file, @options)

            if AnnotationDecider.new(file, @options).annotate?
              if FileAnnotationRemover.call(file, @options)
                unannotated_klass = true
              end

              related_files = RelatedFilesListBuilder.new(file, model_name, table_name, @options).build

              related_files.each do |f, _position_key|
                if File.exist?(f)
                  FileAnnotationRemover.call(f, @options)
                end
              end
            end

            unannotated << klass if unannotated_klass
          rescue StandardError => e
            $stderr.puts "Unable to unannotate #{File.join(file)}: #{e.message}"
            $stderr.puts "\t" + e.backtrace.join("\n\t") if @options[:trace]
          end
        end

        puts "Removed annotations from: #{unannotated.join(', ')}"
      end
    end
  end
end

