# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate with only_file_patterns specified", type: "aruba" do
  let(:command_timeout_seconds) { 10 }
  let(:migration_file) { "20231013230731_add_int_field_to_test_defaults.rb" }
  let(:models_dir) { "app/models" }

  it "avoids annotating a model not given" do
    reset_database
    run_migrations

    # Start with the already annotated TestDefault model
    copy(model_template("test_default.rb"), models_dir)

    original_test_default = read_file(dummyapp_model("test_default.rb"))

    copy(File.join(migrations_template_dir, migration_file), "db/migrate")

    # Apply this specific migration
    _run_migrations_cmd = run_command_and_stop("bin/rails db:migrate:up VERSION=20231013230731", fail_on_error: true, exit_timeout: command_timeout_seconds)
    _run_annotations_cmd = run_command_and_stop("bundle exec annotaterb models --only-file-patterns=nonexistent_model.rb", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_test_default = read_file(dummyapp_model("test_default.rb"))

    # Because the model we restricted ourselves to doesn't exist, we expect the file to remain untouched
    expect(last_command_started).to be_successfully_executed
    expect(annotated_test_default).to eq(original_test_default)
  end
end
