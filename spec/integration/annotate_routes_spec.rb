# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate routes", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  before do
    copy_dummy_app_into_aruba_working_directory

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

  let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/") }
  let(:routes_file) { "config/routes.rb" }

  it "annotates a single file" do
    expected_routes_file = read(File.join(templates_dir, "routes.rb")).join("\n")
    original_routes_file = read(routes_file).join("\n")

    # Check that files have been copied over correctly
    expect(expected_routes_file).not_to eq(original_routes_file)

    _cmd = run_command_and_stop("bundle exec annotaterb routes", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_routes_file = read(routes_file).join("\n")

    expect(last_command_started).to be_successfully_executed
    expect(annotated_routes_file).to eq(expected_routes_file)
  end
end
