# frozen_string_literal: true

require "integration_spec_helper"

RSpec.describe "Generator appends to config file", type: "aruba" do
  supported_config_files = [
    "config/annotaterb.yml",
    ".config/.annotaterb.yml",
    ".config/annotaterb/config.yml"
  ]

  let(:command_timeout_seconds) { 10 }

  let(:config_file) { ".annotaterb.yml" }
  let(:custom_config_file) { "custom_annotaterb.yml" }
  let(:config_file_content) do
    <<~YML.strip
      ---
      :classified_sort: true
      :exclude_controllers: true
      :exclude_factories: false
      :exclude_fixtures: false
      :exclude_helpers: true
      :exclude_scaffolds: true
      :exclude_serializers: false
      :exclude_sti_subclasses: false
      :exclude_tests: false
      :force: false
      :format_markdown: false
      :format_rdoc: false
      :format_yard: false
    YML
  end

  let(:generator_update_config_command) { "bin/rails generate annotate_rb:update_config" }

  it "appends missing configuration key-value pairs" do
    write_file(config_file, config_file_content)

    _cmd = run_command_and_stop(generator_update_config_command, fail_on_error: true, exit_timeout: command_timeout_seconds)

    changed_config_file = read_file(config_file)

    expect(last_command_started).to be_successfully_executed
    expect(config_file_content).not_to eq(changed_config_file)
  end

  supported_config_files.each do |supported_config_file|
    it "appends missing configuration key-value pairs to #{supported_config_file}" do
      write_file(supported_config_file, config_file_content)

      _cmd = run_command_and_stop(generator_update_config_command, fail_on_error: true, exit_timeout: command_timeout_seconds)

      changed_config_file = read_file(supported_config_file)

      expect(last_command_started).to be_successfully_executed
      expect(config_file_content).not_to eq(changed_config_file)
    end
  end

  it "appends missing configuration key-value pairs to the config file specified by --config-path" do
    write_file(config_file, config_file_content)
    write_file(custom_config_file, config_file_content)

    _cmd = run_command_and_stop(
      "#{generator_update_config_command} --config-path=#{custom_config_file}",
      fail_on_error: true,
      exit_timeout: command_timeout_seconds
    )

    changed_default_config_file = read_file(config_file)
    changed_custom_config_file = read_file(custom_config_file)

    expect(last_command_started).to be_successfully_executed
    expect(changed_default_config_file).to eq(config_file_content)
    expect(changed_custom_config_file).not_to eq(config_file_content)
  end
end
