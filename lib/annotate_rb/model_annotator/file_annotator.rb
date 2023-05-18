# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class FileAnnotator
      class << self
        def call_with_instructions(instruction)
          call(instruction.file, instruction.annotation, instruction.position, instruction.options)
        end

        # Add a schema block to a file. If the file already contains
        # a schema info block (a comment starting with "== Schema Information"),
        # check if it matches the block that is already there. If so, leave it be.
        # If not, remove the old info block and write a new one.
        #
        # == Returns:
        # true or false depending on whether the file was modified.
        #
        # === Options (opts)
        #  :force<Symbol>:: whether to update the file even if it doesn't seem to need it.
        #  :position_in_*<Symbol>:: where to place the annotated section in fixture or model file,
        #                           :before, :top, :after or :bottom. Default is :before.
        #
        def call(file_name, info_block, position, options = {})
          # -- Read file
          return false unless File.exist?(file_name)
          old_content = File.read(file_name)

          # -- Validate file should be annotated
          return false if old_content =~ /#{Constants::SKIP_ANNOTATION_PREFIX}.*\n/

          old_columns, new_columns = AnnotationDiffGenerator.new(old_content, info_block).generate

          # -- Validate file should be annotated part 2
          return false if old_columns == new_columns && !options[:force]

          abort "AnnotateRb error. #{file_name} needs to be updated, but annotaterb was run with `--frozen`." if options[:frozen]

          # -- Update annotation if it exists
          # Replace inline the old schema info with the new schema info
          wrapper_open = options[:wrapper_open] ? "# #{options[:wrapper_open]}\n" : ""
          wrapper_close = options[:wrapper_close] ? "# #{options[:wrapper_close]}\n" : ""
          wrapped_info_block = "#{wrapper_open}#{info_block}#{wrapper_close}"

          annotation_pattern = AnnotationPatternGenerator.call(options)
          old_annotation = old_content.match(annotation_pattern).to_s

          # if there *was* no old schema info or :force was passed, we simply
          # need to insert it in correct position
          if old_annotation.empty? || options[:force]
            magic_comments_block = Helper.magic_comments_as_string(old_content)
            old_content.gsub!(Constants::MAGIC_COMMENT_MATCHER, '')

            annotation_pattern = AnnotationPatternGenerator.call(options)
            old_content.sub!(annotation_pattern, '')

            new_content = if %w(after bottom).include?(options[position].to_s)
                            magic_comments_block + (old_content.rstrip + "\n\n" + wrapped_info_block)
                          elsif magic_comments_block.empty?
                            magic_comments_block + wrapped_info_block + old_content.lstrip
                          else
                            magic_comments_block + "\n" + wrapped_info_block + old_content.lstrip
                          end
          else
            # replace the old annotation with the new one

            # keep the surrounding whitespace the same
            space_match = old_annotation.match(/\A(?<start>\s*).*?\n(?<end>\s*)\z/m)
            new_annotation = space_match[:start] + wrapped_info_block + space_match[:end]

            annotation_pattern = AnnotationPatternGenerator.call(options)
            new_content = old_content.sub(annotation_pattern, new_annotation)
          end

          File.open(file_name, 'wb') { |f| f.puts new_content }
          true
        end
      end
    end
  end
end
