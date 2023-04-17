require 'annotate_rb'

module AnnotateRb
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Copy annotaterb rakefiles for automatic annotation of models and routes'
      source_root File.expand_path('templates', __dir__)

      def copy_tasks
        # Copies the rake task into Rails project's lib/tasks directory
        template 'auto_annotate_models.rake', 'lib/tasks/auto_annotate_models.rake'
      end
    end
  end
end
