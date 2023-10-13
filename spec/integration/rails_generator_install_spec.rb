# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Generator installs rake file", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  before do
    copy(Dir[File.join(aruba.config.root_directory, "spec/dummyapp/*")], aruba.config.home_directory)

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

  let(:rake_task_file) { "lib/tasks/annotate_rb.rake" }
  let(:rake_task) { File.join(aruba.config.root_directory, "lib/generators/annotate_rb/install/templates/annotate_rb.rake") }

  let(:generator_install_command) { "bin/rails generate annotate_rb:install" }

  it "installs the rake file to Rails project" do
    # First check that the file doesn't exist in dummyapp
    expect(exist?(rake_task_file)).to be_falsey

    _cmd = run_command_and_stop(generator_install_command, fail_on_error: true, exit_timeout: command_timeout_seconds)

    installed_rake_task = read(rake_task_file).join("\n")
    # Read the one in the actual gem
    actual_rake_task = read(rake_task).join("\n")

    expect(last_command_started).to be_successfully_executed
    expect(installed_rake_task).to eq(actual_rake_task)
  end
end
