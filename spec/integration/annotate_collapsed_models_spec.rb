# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate collapsed models", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  context "when annotating collapsed models" do
    it "annotates them correctly" do
      reset_database
      run_migrations

      expected_test_model = read_file(model_template("collapsed_test_model.rb"))

      original_test_model = read_file(dummyapp_model("collapsed/example/test_model.rb"))

      expect(expected_test_model).not_to eq(original_test_model)

      _cmd = run_command_and_stop("bundle exec annotate_rb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

      annotated_test_model = read_file(dummyapp_model("collapsed/example/test_model.rb"))

      expect(last_command_started).to be_successfully_executed
      expect(expected_test_model).to eq(annotated_test_model)
    end
  end
end
