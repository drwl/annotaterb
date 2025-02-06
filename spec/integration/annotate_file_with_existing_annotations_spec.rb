# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate a file with existing annotations", type: "aruba" do
  let(:command_timeout_seconds) { 10 }
  let(:models_dir) { "app/models" }
  let(:model_file) { "app/models/test_default.rb" }

  context "when using 'force' option and 'position: bottom'" do
    before do
      # Copy file with existing annotations at the top
      copy(model_template("test_default.rb"), "app/models")

      reset_database
      run_migrations
    end

    it "moves annotations to the bottom of the file" do
      expected_test_default = read_file(model_template("test_default_with_bottom_annotations.rb"))
      original_test_default = read_file(dummyapp_model("test_default.rb"))

      # Check that files have been copied over correctly
      expect(expected_test_default).not_to eq(original_test_default)

      _cmd = run_command_and_stop(
        "bundle exec annotate_rb models #{model_file} --force --position bottom",
        fail_on_error: true,
        exit_timeout: command_timeout_seconds
      )

      annotated_test_default = read_file(dummyapp_model("test_default.rb"))

      expect(last_command_started).to be_successfully_executed
      expect(annotated_test_default).to eq(expected_test_default)
    end
  end
end
