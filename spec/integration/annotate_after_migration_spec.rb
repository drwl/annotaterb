# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate after running migrations", type: "aruba" do
  let(:command_timeout_seconds) { 10 }
  let(:migration_file) { "20231013230731_add_int_field_to_test_defaults.rb" }
  let(:models_dir) { "app/models" }

  it "adds annotations for the new field" do
    reset_database
    run_migrations

    # Start with the already annotated TestDefault model
    copy(File.join(models_template_dir, "test_default.rb"), models_dir)

    expected_test_default = read_file(File.join(models_template_dir, "test_default_updated.rb"))
    original_test_default = read_file(File.join(models_dir, "test_default.rb"))

    # Check that files have been copied over correctly
    expect(expected_test_default).not_to eq(original_test_default)

    copy(File.join(migrations_template_dir, migration_file), "db/migrate")

    _run_migrations_cmd = run_command_and_stop("bin/rails db:migrate VERSION=20231013230731", fail_on_error: true, exit_timeout: command_timeout_seconds)
    _run_annotations_cmd = run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_test_default = read_file(File.join(models_dir, "test_default.rb"))

    expect(last_command_started).to be_successfully_executed
    expect(annotated_test_default).to eq(expected_test_default)
  end

  context "when the rake task that hooks into database migration exists" do
    before do
      _cmd = run_command_and_stop("bin/rails g annotate_rb:install", fail_on_error: true, exit_timeout: command_timeout_seconds)
    end

    it "annotations are automatically added during migration" do
      reset_database

      expected_test_default = read_file(File.join(models_template_dir, "test_default_updated.rb"))
      original_test_default = read_file(File.join(models_dir, "test_default.rb"))

      # Check that files have been copied over correctly
      expect(expected_test_default).not_to eq(original_test_default)

      copy(File.join(migrations_template_dir, migration_file), "db/migrate")

      _run_migrations_cmd = run_command_and_stop("bin/rails db:migrate", fail_on_error: true, exit_timeout: command_timeout_seconds)

      annotated_test_default = read_file(File.join(models_dir, "test_default.rb"))

      expect(last_command_started).to be_successfully_executed
      expect(annotated_test_default).to eq(expected_test_default)
    end
  end
end
