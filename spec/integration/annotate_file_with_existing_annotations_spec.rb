# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate a file with existing annotations", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/#{ENV["DATABASE_ADAPTER"]}") }
  let(:model_file) { "app/models/test_default.rb" }

  context "when using 'force' option and 'position: bottom'" do
    before do
      # Copy file with existing annotations at the top
      copy(File.join(templates_dir, "test_default.rb"), "app/models")

      reset_database
      run_migrations
    end

    it "moves annotations to the bottom of the file" do
      expected_test_default = read_file(File.join(templates_dir, "test_default_with_bottom_annotations.rb"))
      original_test_default = read_file(File.join(models_dir, "test_default.rb"))

      # Check that files have been copied over correctly
      expect(expected_test_default).not_to eq(original_test_default)

      _cmd = run_command_and_stop(
        "bundle exec annotaterb models #{model_file} --force --position bottom",
        fail_on_error: true,
        exit_timeout: command_timeout_seconds
      )

      annotated_test_default = read_file(File.join(models_dir, "test_default.rb"))

      expect(last_command_started).to be_successfully_executed
      expect(annotated_test_default).to eq(expected_test_default)
    end
  end
end
