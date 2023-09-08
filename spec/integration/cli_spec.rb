# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "CLI", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  before do
    copy(Dir[File.join(aruba.config.root_directory, "spec/dummyapp/*")], aruba.config.home_directory)

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

  context "when running in a non-Rails project directory" do
    before do
      remove("Rakefile") if exist?("Rakefile")
      remove("Gemfile") if exist?("Gemfile")
    end

    let(:error_message) { "Please run annotaterb from the root of the project." }

    it "exits and outputs an error message" do
      _cmd = run_command("bundle exec annotaterb")

      expect(last_command_started).to have_exit_status(1)
      expect(last_command_started).to have_output_on_stderr(error_message)
    end
  end

  context "when running in a directory with a Rakefile and a Gemfile" do
    let(:help_banner_fragment) { "Usage: annotaterb [command] [options]" }
    let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/#{ENV["DATABASE_ADAPTER"]}") }

    it "outputs the help message" do
      _cmd = run_command("bundle exec annotaterb", fail_on_error: true, exit_timeout: command_timeout_seconds)

      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to include(help_banner_fragment)
    end

    it "annotates files that have not been annotated" do
      expected_test_default = read(File.join(templates_dir, "test_default.rb")).join("\n")
      expected_test_null_false = read(File.join(templates_dir, "test_null_false.rb")).join("\n")

      original_test_default = read(File.join(models_dir, "test_default.rb")).join("\n")
      original_test_null_false = read(File.join(models_dir, "test_null_false.rb")).join("\n")

      expect(expected_test_default).not_to eq(original_test_default)
      expect(expected_test_null_false).not_to eq(original_test_null_false)

      _cmd = run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

      annotated_test_default = read(File.join(models_dir, "test_default.rb")).join("\n")
      annotated_test_null_false = read(File.join(models_dir, "test_null_false.rb")).join("\n")

      expect(last_command_started).to be_successfully_executed
      expect(expected_test_default).to eq(annotated_test_default)
      expect(expected_test_null_false).to eq(annotated_test_null_false)
    end
  end
end
