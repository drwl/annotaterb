# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Annotate STI models", type: "aruba" do
  let(:models_dir) { "app/models" }
  let(:command_timeout_seconds) { 10 }

  it "annotates them correctly" do
    reset_database
    run_migrations

    # Pseudo STI model does not have a `type` field, where the True STI model does.
    # Both inherit/subclass from another model.
    expected_pseudo_sti_model = read_file(model_template("test_sibling_default.rb"))
    original_pseudo_sti_model = read_file(dummyapp_model("test_sibling_default.rb"))
    expect(expected_pseudo_sti_model).not_to eq(original_pseudo_sti_model)

    expected_true_sti_model = read_file(model_template("test_true_sti.rb"))
    original_true_sti_model = read_file(dummyapp_model("test_true_sti.rb"))
    expect(expected_true_sti_model).not_to eq(original_true_sti_model)

    _cmd = run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    expect(last_command_started).to be_successfully_executed

    annotated_pseudo_sti_model = read_file(dummyapp_model("test_sibling_default.rb"))
    expect(expected_pseudo_sti_model).to eq(annotated_pseudo_sti_model)

    annotated_true_sti_model = read_file(dummyapp_model("test_true_sti.rb"))
    expect(expected_true_sti_model).to eq(annotated_true_sti_model)
  end

  it "does not annotate when excluding sti subclasses" do
    reset_database
    run_migrations

    expected_pseudo_sti_model = read_file(model_template("test_sibling_default.rb"))
    original_pseudo_sti_model = read_file(dummyapp_model("test_sibling_default.rb"))
    expect(expected_pseudo_sti_model).to_not eq(original_pseudo_sti_model)

    expected_true_sti_model = read_file(model_template("test_true_sti.rb"))
    original_true_sti_model = read_file(dummyapp_model("test_true_sti.rb"))
    expect(expected_true_sti_model).not_to eq(original_true_sti_model)

    _cmd = run_command_and_stop("bundle exec annotaterb models --exclude sti_subclasses", fail_on_error: true, exit_timeout: command_timeout_seconds)

    expect(last_command_started).to be_successfully_executed

    annotated_pseudo_sti_model = read_file(dummyapp_model("test_sibling_default.rb"))
    expect(expected_pseudo_sti_model).to_not eq(annotated_pseudo_sti_model)

    annotated_true_sti_model = read_file(dummyapp_model("test_true_sti.rb"))
    expect(expected_true_sti_model).to_not eq(annotated_true_sti_model)
  end
end
