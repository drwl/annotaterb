# frozen_string_literal: true

module AnnotateRb
  module Commands
    class AnnotateRoutes
      def call(options)
        puts "Annotating routes"
        AnnotateRb::RouteAnnotator::Annotator.send(options[:target_action], options)
      end
    end
  end
end

