# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "CLI", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

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

    it "outputs the help message" do
      _cmd = run_command("bundle exec annotaterb", fail_on_error: true, exit_timeout: command_timeout_seconds)

      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to include(help_banner_fragment)
    end

    it "annotates files that have not been annotated" do
      reset_database
      run_migrations

      expected_test_default = read_file(model_template("test_default.rb"))
      expected_test_null_false = read_file(model_template("test_null_false.rb"))

      original_test_default = read_file(dummyapp_model("test_default.rb"))
      original_test_null_false = read_file(dummyapp_model("test_null_false.rb"))

      expect(expected_test_default).not_to eq(original_test_default)
      expect(expected_test_null_false).not_to eq(original_test_null_false)

      _cmd = run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

      annotated_test_default = read_file(dummyapp_model("test_default.rb"))
      annotated_test_null_false = read_file(dummyapp_model("test_null_false.rb"))

      expect(last_command_started).to be_successfully_executed
      expect(expected_test_default).to eq(annotated_test_default)
      expect(expected_test_null_false).to eq(annotated_test_null_false)
    end
  end
end
