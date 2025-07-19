# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate with --show-migration option", type: "aruba" do
  let(:command_timeout_seconds) { 10 }
  let(:model_file) { "app/models/test_default.rb" }

  it "includes migration version numbers in annotations" do
    reset_database
    run_migrations

    # Get primary database version
    _primary_version_cmd = run_command_and_stop(
      "bundle exec rails db:version",
      fail_on_error: true,
      exit_timeout: command_timeout_seconds
    )
    primary_version = last_command_started.stdout.match(/Current version: (\d+)/)[1]

    # Get secondary database version
    _secondary_version_cmd = run_command_and_stop(
      "bundle exec rails db:version:secondary",
      fail_on_error: true,
      exit_timeout: command_timeout_seconds
    )
    secondary_version = last_command_started.stdout.match(/Current version: (\d+)/)[1]

    # Run annotation with --show-migration option
    _cmd = run_command_and_stop(
      "bundle exec annotaterb models --show-migration",
      fail_on_error: true,
      exit_timeout: command_timeout_seconds
    )

    primary_content = read_file(dummyapp_model("test_default.rb"))
    secondary_content = read_file(dummyapp_model("secondary/test_default.rb"))

    expect(last_command_started).to be_successfully_executed

    # Verify that migration version numbers are included in the annotation
    expect(primary_content).to match(/# Schema version: #{primary_version}/)
    expect(secondary_content).to match(/# Schema version: #{secondary_version}/)
  end
end
