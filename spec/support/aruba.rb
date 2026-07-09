# frozen_string_literal: true

require "aruba/rspec"

module SpecHelper
  module Aruba
    def read_file(name)
      # Aruba's #read uses File.readlines, returning an Array
      read(name).join("\n")
    end

    def models_template_dir
      File.join(::Aruba.config.root_directory, "spec/templates/#{ENV["DATABASE_ADAPTER"]}")
    end

    def migrations_template_dir
      File.join(::Aruba.config.root_directory, "spec/templates/migrations")
    end

    def model_template(name)
      # Rails 8 changed TimeWithZone#inspect to ISO 8601 (https://github.com/rails/rails/pull/52371),
      # so datetime defaults in schema comments differ from Rails 7.2. spec/templates/rails8/
      # holds those overrides; if we drop Rails 7.2 from the CI matrix, this branch can go away.
      if ENV.fetch("RAILS_VERSION", "~> 7.2.0")[/(\d+)\./, 1].to_i >= 8
        rails8_path = File.join(::Aruba.config.root_directory, "spec/templates/rails8/#{ENV["DATABASE_ADAPTER"]}", name)
        return rails8_path if File.exist?(rails8_path)
      end

      File.join(models_template_dir, name)
    end

    def dummyapp_model(name)
      File.join(aruba_working_directory, "app/models", name)
    end

    def aruba_working_directory
      File.expand_path("../../#{::Aruba.config.working_directory}", __dir__)
    end

    def dummy_app_directory
      File.expand_path("../../spec/dummyapp/", __dir__)
    end

    def copy_dummy_app_into_aruba_working_directory
      FileUtils.rm_rf(Dir.glob("#{aruba_working_directory}/**/*"))
      FileUtils.cp_r(Dir.glob("#{dummy_app_directory}/."), aruba_working_directory)
    end

    def reset_database
      run_command_and_stop("bin/rails db:drop db:create", fail_on_error: true, exit_timeout: 10)
    end

    def run_migrations
      run_command_and_stop("bin/rails db:migrate", fail_on_error: true, exit_timeout: 10)
    end
  end
end
