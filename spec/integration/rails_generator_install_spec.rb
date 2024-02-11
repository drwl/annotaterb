# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Generator installs rake file", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  before do
    copy_dummy_app_into_aruba_working_directory

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

  let(:rake_task_file) { "lib/tasks/annotate_rb.rake" }
  let(:rake_task) { File.join(aruba.config.root_directory, "lib/generators/annotate_rb/hook/templates/annotate_rb.rake") }
  let(:config_file) { ".annotaterb.yml" }

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

  it "generates a default config file" do
    # First check that the file doesn't exist in dummyapp
    expect(exist?(config_file)).to be_falsey

    _cmd = run_command_and_stop(generator_install_command, fail_on_error: true, exit_timeout: command_timeout_seconds)

    expect(exist?(config_file)).to be_truthy

    expect(last_command_started).to be_successfully_executed
  end

  context "when the rake task already exists" do
    before do
      touch(rake_task_file)
    end

    it "returns the Thor cli" do
      # First check that the file exists in dummyapp
      expect(exist?(rake_task_file)).to be_truthy

      # TODO: Improve this so we don't have to rely on `exit_timeout`
      _cmd = run_command(generator_install_command, exit_timeout: 3)

      # When the file already exists, the default behavior is the Thor CLI prompts user on how to proceed
      # https://github.com/rails/thor/blob/a4d99cfc97691504d26d0d0aefc649a8f2e89b3c/spec/actions/create_file_spec.rb#L112
      expect(all_stdout).to include("conflict")
    end
  end
end
