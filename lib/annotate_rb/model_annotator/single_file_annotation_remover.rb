# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class SingleFileAnnotationRemover
      class << self
        def call_with_instructions(instruction)
          call(instruction.file, instruction.options)
        end

        def call(file_name, options = Options.from({}))
          return false unless File.exist?(file_name)
          old_content = File.read(file_name)

          begin
            parsed_file = FileParser::ParsedFile.new(old_content, "", options).tap(&:parse)
          rescue FileParser::AnnotationFinder::MalformedAnnotation => e
            warn "Unable to process #{file_name}: #{e.message}"
            warn "\t" + e.backtrace.join("\n\t") if @options[:trace]
            return false
          rescue FileParser::AnnotationFinder::NoAnnotationFound => _e
            return false # False since there's no annotations to remove
          end

          return false if parsed_file.has_skip_string?

          updated_file_content = old_content.sub(parsed_file.annotations_with_whitespace, "")

          File.open(file_name, "wb") { |f| f.puts updated_file_content }

          true
        end
      end
    end
  end
end
