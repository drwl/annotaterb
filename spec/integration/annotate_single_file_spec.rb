# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate a single file", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/#{ENV["DATABASE_ADAPTER"]}") }
  let(:model_file) { "app/models/test_default.rb" }

  it "annotates a single file" do
    reset_database
    run_migrations

    expected_test_default = read_file(File.join(templates_dir, "test_default.rb"))
    expected_test_null_false = read_file(File.join(templates_dir, "test_null_false.rb"))

    original_test_default = read_file(File.join(models_dir, "test_default.rb"))
    original_test_null_false = read_file(File.join(models_dir, "test_null_false.rb"))

    # Check that files have been copied over correctly
    expect(expected_test_default).not_to eq(original_test_default)
    expect(expected_test_null_false).not_to eq(original_test_null_false)

    _cmd = run_command_and_stop("bundle exec annotaterb models #{model_file}", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_test_default = read_file(File.join(models_dir, "test_default.rb"))
    annotated_test_null_false = read_file(File.join(models_dir, "test_null_false.rb"))

    expect(last_command_started).to be_successfully_executed
    expect(annotated_test_default).to eq(expected_test_default)
    expect(annotated_test_null_false).not_to eq(expected_test_null_false)
  end
end
