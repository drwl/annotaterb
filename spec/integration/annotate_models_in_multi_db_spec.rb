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
end
