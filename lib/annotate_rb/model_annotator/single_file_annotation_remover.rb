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

          file_components = FileComponents.new(old_content, '', options)

          return false if file_components.has_skip_string?
          # TODO: Uncomment below after tests are fixed
          # return false if !file_components.has_annotations?

          if options[:wrapper_open]
            wrapper_open = "# #{options[:wrapper_open]}\n"
          else
            wrapper_open = ''
          end

          generated_pattern = AnnotationPatternGenerator.call(options)
          updated_file_content = old_content.sub!(/(#{wrapper_open})?#{generated_pattern}/, '')

          File.open(file_name, 'wb') { |f| f.puts updated_file_content }

          true
        end
      end
    end
  end
end
