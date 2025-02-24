# frozen_string_literal: true

module Annotaterb
  module Commands
    class AnnotateRoutes
      def call(options)
        puts "Annotating routes"

        if options[:debug]
          puts "Running with debug mode, options:"
          pp options.to_h
        end

        Annotaterb::RouteAnnotator::Annotator.send(options[:target_action], options)
      end
    end
  end
end
