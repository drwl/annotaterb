# frozen_string_literal: true

module Annotaterb
  module Commands
    class AnnotateModels
      def call(options)
        puts "Annotating models"

        if options[:debug]
          puts "Running with debug mode, options:"
          pp options.to_h
        end

        # Eager load Models when we're annotating models
        Annotaterb::EagerLoader.call(options)

        Annotaterb::ModelAnnotator::Annotator.send(options[:target_action], options)
      end
    end
  end
end
