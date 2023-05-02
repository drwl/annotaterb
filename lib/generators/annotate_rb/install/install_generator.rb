# frozen_string_literal: true
require 'annotate_rb'

module AnnotateRb
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_task
        copy_file "auto_annotate_models.rake", "lib/tasks/auto_annotate_models.rake"
      end
    end
  end
end
