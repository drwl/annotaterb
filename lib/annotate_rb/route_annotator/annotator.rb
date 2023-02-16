# frozen_string_literal: true

module AnnotateRb
  module RouteAnnotator
    class Annotator
      class << self
        def add_annotations(options = {})
          new(options).add_annotations
        end

        def remove_annotations(options = {})
          new(options).remove_annotations
        end
      end

      def initialize(options = {})
        @options = options
      end

      def add_annotations
        if Helper.routes_file_exist?
          existing_text = File.read(Helper.routes_file)
          content, header_position = Helper.strip_annotations(existing_text)
          new_content = annotate_routes(HeaderGenerator.generate(@options), content, header_position, @options)
          new_text = new_content.join("\n")

          if Helper.rewrite_contents(existing_text, new_text)
            puts "#{Helper.routes_file} was annotated."
          else
            puts "#{Helper.routes_file} was not changed."
          end
        else
          puts "#{Helper.routes_file} could not be found."
        end
      end

      def remove_annotations
        if Helper.routes_file_exist?
          existing_text = File.read(Helper.routes_file)
          content, header_position = Helper.strip_annotations(existing_text)
          new_content = Helper.strip_on_removal(content, header_position)
          new_text = new_content.join("\n")
          if Helper.rewrite_contents(existing_text, new_text)
            puts "Annotations were removed from #{Helper.routes_file}."
          else
            puts "#{Helper.routes_file} was not changed (Annotation did not exist)."
          end
        else
          puts "#{Helper.routes_file} could not be found."
        end
      end

      def annotate_routes(header, content, header_position, options = {})
        magic_comments_map, content = Helper.extract_magic_comments_from_array(content)
        if %w(before top).include?(options[:position_in_routes])
          header = header << '' if content.first != ''
          magic_comments_map << '' if magic_comments_map.any?
          new_content = magic_comments_map + header + content
        else
          # Ensure we have adequate trailing newlines at the end of the file to
          # ensure a blank line separating the content from the annotation.
          content << '' unless content.last == ''

          # We're moving something from the top of the file to the bottom, so ditch
          # the spacer we put in the first time around.
          content.shift if header_position == :before && content.first == ''

          new_content = magic_comments_map + content + header
        end

        # Make sure we end on a trailing newline.
        new_content << '' unless new_content.last == ''

        new_content
      end
    end
  end
end
