# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate models in a multi-db environment with duplicate table names", type: "aruba" do
  include_context "when in a multi database environment"

  let(:command_timeout_seconds) { 10 }

  # Test that running `bundle exec annotate models` twice results in no changes on the second run
  it "does not change fixture annotations on second run" do
    reset_database
    run_migrations

    # First run (apply annotations)
    run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    # Second run (ensure no changes)
    run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    # Get output of the second run
    second_run_output = last_command_started.output

    # Ensure "Model files unchanged." is included in the output
    expect(second_run_output).to include("Model files unchanged.")
  end

  it "includes the database name in the annotation for secondary models" do
    reset_database
    run_migrations

    run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    content = read_file(dummyapp_model("secondary/test_default.rb"))
    expect(content).to include("# Database name: secondary")
  end

  it "does not include the database name when ignore_multi_database_name is true" do
    reset_database
    run_migrations

    # Create config file with ignore_multi_database_name option
    config_content = <<~YAML.strip
      ignore_multi_database_name: true
    YAML
    write_file(".annotaterb.yml", config_content)

    run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    primary_content = read_file(dummyapp_model("test_default.rb"))
    secondary_content = read_file(dummyapp_model("secondary/test_default.rb"))

    # Neither model should include the database name
    expect(primary_content).not_to include("# Database name: primary")
    expect(secondary_content).not_to include("# Database name: secondary")
  end
end
