# frozen_string_literal: true

module AnnotateRb
  module Commands
    class AnnotateModels
      def call(options)
        puts "Annotating models"
        AnnotateRb::ModelAnnotator::Annotator.send(options[:target_action], options)
      end
    end
  end
end

