# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate routes", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/") }
  let(:routes_file) { "config/routes.rb" }

  it "annotates a single file" do
    expected_routes_file = read_file(File.join(templates_dir, "routes.rb"))
    original_routes_file = read_file(routes_file)

    # Check that files have been copied over correctly
    expect(expected_routes_file).not_to eq(original_routes_file)

    _cmd = run_command_and_stop("bundle exec annotaterb routes", fail_on_error: true, exit_timeout: command_timeout_seconds)

    annotated_routes_file = read_file(routes_file)

    expect(last_command_started).to be_successfully_executed
    expect(annotated_routes_file).to eq(expected_routes_file)
  end
end
