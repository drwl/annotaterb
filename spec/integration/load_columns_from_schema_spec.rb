# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Load columns from schema with ignored columns", type: "aruba" do
  let(:command_timeout_seconds) { 10 }
  let(:model_file) { "app/models/test_default.rb" }

  before do
    copy_dummy_app_into_aruba_working_directory
    reset_database
    run_migrations
  end

  it "does not include ignored columns by default" do
    run_command_and_stop("bundle exec annotaterb models #{model_file} --force", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_content = read_file(model_file)

    expect(annotated_content).to include("string")
    expect(annotated_content).not_to include("#  ignored_column")
  end

  it "includes ignored columns when --load-columns-from-schema is used" do
    run_command_and_stop("bundle exec annotaterb models #{model_file} --load-columns-from-schema --force", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_content = read_file(model_file)

    expect(annotated_content).to include("string")
    expect(annotated_content).to include("#  ignored_column")
  end
end
