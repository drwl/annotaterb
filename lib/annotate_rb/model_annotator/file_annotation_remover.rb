# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class FileAnnotationRemover
      class << self
        def call(file_name, options = Options.from({}))
          if File.exist?(file_name)
            content = File.read(file_name)
            return false if content =~ /#{Constants::SKIP_ANNOTATION_PREFIX}.*\n/

            if options[:wrapper_open]
              wrapper_open = "# #{options[:wrapper_open]}\n"
            else
              wrapper_open = ''
            end

            content.sub!(/(#{wrapper_open})?#{AnnotationPatternGenerator.call(options)}/, '')

            File.open(file_name, 'wb') { |f| f.puts content }

            true
          else
            false
          end
        end
      end
    end
  end
end
