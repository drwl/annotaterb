# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate after running migrations", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  before do
    copy(Dir[File.join(aruba.config.root_directory, "spec/dummyapp/*")], aruba.config.home_directory)

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

  let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/#{ENV["DATABASE_ADAPTER"]}") }
  let(:migrations_templates_dir) { File.join(aruba.config.root_directory, "spec/templates/migrations") }
  let(:migration_file) { "20231013230731_add_int_field_to_test_defaults.rb" }

  let(:models_dir) { "app/models" }

  it "adds annotations for the new field" do
    expected_test_default = read(File.join(templates_dir, "test_default_updated.rb")).join("\n")
    original_test_default = read(File.join(models_dir, "test_default.rb")).join("\n")

    # Check that files have been copied over correctly
    expect(expected_test_default).not_to eq(original_test_default)

    copy(File.join(migrations_templates_dir, migration_file), "db/migrate")

    _run_migrations_cmd = run_command_and_stop("bin/rails db:migrate", fail_on_error: true, exit_timeout: command_timeout_seconds)
    _run_annotations_cmd = run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_test_default = read(File.join(models_dir, "test_default.rb")).join("\n")

    expect(last_command_started).to be_successfully_executed
    expect(annotated_test_default).to eq(expected_test_default)
  end
end
