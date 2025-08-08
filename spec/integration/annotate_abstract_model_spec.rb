require "integration_spec_helper"

RSpec.describe "Annotate abstract model in single DB config", type: "aruba" do
  let(:command_timeout_seconds) { 10 }

  before do
    require "yaml"
    require "erb"

    # Dynamically build a single DB config from the multi-DB config
    multi_db_config_path = File.join(dummy_app_directory, "config/database.yml")
    multi_db_config_erb = ERB.new(File.read(multi_db_config_path)).result
    multi_db_config = YAML.safe_load(multi_db_config_erb, aliases: true)

    single_db_config = {"development" => multi_db_config["development"]["primary"]}

    write_file("config/database.yml", single_db_config.to_yaml)
  end

  it "does not raise an error and correctly annotates other models" do
    reset_database
    run_migrations

    original_abstract_model = read_file(dummyapp_model("abstract_model.rb"))

    run_command_and_stop("bundle exec annotaterb models", fail_on_error: true, exit_timeout: command_timeout_seconds)

    expect(last_command_started).to be_successfully_executed

    annotated_abstract_model = read_file(dummyapp_model("abstract_model.rb"))
    expect(annotated_abstract_model).to eq(original_abstract_model)

    annotated_test_default = read_file(dummyapp_model("test_default.rb"))
    expected_test_default = read_file(model_template("test_default.rb"))

    expect(annotated_test_default).to eq(expected_test_default)
  end
end
