# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate a file with existing annotations", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  before do
    copy(Dir[File.join(aruba.config.root_directory, "spec/dummyapp/*")], aruba.config.home_directory)

    # Unset the bundler context from running annotaterb integration specs.
    #   This way, when `run_command("bundle exec annotaterb")` runs, it runs as if it's within the context of dummyapp.
    unset_bundler_env_vars
  end

  let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/#{ENV["DATABASE_ADAPTER"]}") }
  let(:model_file) { "app/models/test_default.rb" }

  context "when using 'force' option and 'position: bottom'" do
    before do
      # Copy file with existing annotations at the top
      copy(File.join(templates_dir, "test_default.rb"), "app/models")
    end

    it "moves annotations to the bottom of the file" do
      expected_test_default = read(File.join(templates_dir, "test_default_with_bottom_annotations.rb")).join("\n")
      original_test_default = read(File.join(models_dir, "test_default.rb")).join("\n")

      # Check that files have been copied over correctly
      expect(expected_test_default).not_to eq(original_test_default)

      _cmd = run_command_and_stop(
        "bundle exec annotaterb models #{model_file} --force --position bottom",
        fail_on_error: true,
        exit_timeout: command_timeout_seconds
      )

      annotated_test_default = read(File.join(models_dir, "test_default.rb")).join("\n")

      expect(last_command_started).to be_successfully_executed
      expect(annotated_test_default).to eq(expected_test_default)
    end
  end
end
