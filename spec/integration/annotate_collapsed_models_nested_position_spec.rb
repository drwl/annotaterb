# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate collapsed models with --nested-position", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  context "when annotating collapsed models with --nested-position" do
    it "inserts annotation inside the module, above the class" do
      reset_database
      run_migrations

      expected = read_file(model_template("nested_position_collapsed_test_model.rb"))

      run_command_and_stop("bundle exec annotaterb models --nested-position", fail_on_error: false, exit_timeout: command_timeout_seconds)
      annotated = read_file(dummyapp_model("collapsed/example/test_model.rb"))
      expect(annotated).to eq(expected)
    end
  end
end
