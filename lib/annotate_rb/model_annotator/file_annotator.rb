# frozen_string_literal: true

module AnnotateRb
  module ModelAnnotator
    class FileAnnotator
      class << self
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
          return false if old_content =~ /#{Constants::SKIP_ANNOTATION_PREFIX}.*\n/

          # Ignore the Schema version line because it changes with each migration
          header_pattern = /(^# Table name:.*?\n(#.*[\r]?\n)*[\r]?)/
          old_header = old_content.match(header_pattern).to_s
          new_header = info_block.match(header_pattern).to_s

          column_pattern = /^#[\t ]+[\w\*\.`]+[\t ]+.+$/
          old_columns = old_header && old_header.scan(column_pattern).sort
          new_columns = new_header && new_header.scan(column_pattern).sort

          return false if old_columns == new_columns && !options[:force]

          abort "annotate error. #{file_name} needs to be updated, but annotate was run with `--frozen`." if options[:frozen]

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
            old_content.gsub!(Annotator::MAGIC_COMMENT_MATCHER, '')

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
