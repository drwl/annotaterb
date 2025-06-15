require "integration_spec_helper"

RSpec.describe "Generator installs rake file", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  let(:rake_task_file) { "lib/tasks/annotate_rb.rake" }
  let(:rake_task) { File.join(aruba.config.root_directory, "lib/generators/annotate_rb/hook/templates/annotate_rb.rake") }
  let(:config_file) { ".annotate_rb.yml" }

  let(:generator_install_command) { "bin/rails generate annotate_rb:install" }

  it "installs the rake file to Rails project" do
    # First check that the file doesn't exist in dummyapp
    expect(exist?(rake_task_file)).to be_falsey

    _cmd = run_command_and_stop(generator_install_command, fail_on_error: true, exit_timeout: command_timeout_seconds)

    installed_rake_task = read_file(rake_task_file)
    # Read the one in the actual gem
    actual_rake_task = read_file(rake_task)

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
      _cmd = run_command(generator_install_command, exit_timeout: 5)
      # Because the rake task file already exists, there will be a conflict in the Rails generator.
      # The prompt should look something like this:
      #
      # ...
      #     generate  annotate_rb:hook
      #        rails  generate annotate_rb:hook
      #     conflict  lib/tasks/annotate_rb.rake
      # Overwrite .../dummyapp/lib/tasks/annotate_rb.rake? (enter "h" for help) [Ynaqdhm]
      type("q") # Quit the command

      # When the file already exists, the default behavior is the Thor CLI prompts user on how to proceed
      # https://github.com/rails/thor/blob/a4d99cfc97691504d26d0d0aefc649a8f2e89b3c/spec/actions/create_file_spec.rb#L112
      expect(all_stdout).to include("conflict")
    end
  end
end
