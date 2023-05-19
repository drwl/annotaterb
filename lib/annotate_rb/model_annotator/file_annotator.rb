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
          return false unless File.exist?(file_name)
          old_content = File.read(file_name)

          parsed_file = AnnotatedFileParser.new(old_content, info_block, options)
          parsed_file.parse

          return false if parsed_file.skip?
          return false if !parsed_file.annotations_changed? && !options[:force]

          abort "AnnotateRb error. #{file_name} needs to be updated, but annotaterb was run with `--frozen`." if options[:frozen]

          # if there *was* no old schema info or :force was passed, we simply need to insert it in correct position
          if parsed_file.old_annotations_v1.empty? || options[:force]
            magic_comments_block = Helper.magic_comments_as_string(old_content)
            old_content.gsub!(Constants::MAGIC_COMMENT_MATCHER, '')

            old_content.sub!(parsed_file.annotation_pattern, '')

            new_content = if %w(after bottom).include?(options[position].to_s)
                            magic_comments_block + (old_content.rstrip + "\n\n" + parsed_file.new_wrapped_annotations)
                          elsif magic_comments_block.empty?
                            magic_comments_block + parsed_file.new_wrapped_annotations + old_content.lstrip
                          else
                            magic_comments_block + "\n" + parsed_file.new_wrapped_annotations + old_content.lstrip
                          end
          else
            # replace the old annotation with the new one

            # keep the surrounding whitespace the same
            space_match = parsed_file.old_annotations_v1.match(/\A(?<start>\s*).*?\n(?<end>\s*)\z/m)
            new_annotation = space_match[:start] + parsed_file.new_wrapped_annotations + space_match[:end]

            new_content = old_content.sub(parsed_file.annotation_pattern, new_annotation)
          end

          updated_file_content = new_content
          File.open(file_name, 'wb') { |f| f.puts updated_file_content }
          true
        end
      end
    end
  end
end
