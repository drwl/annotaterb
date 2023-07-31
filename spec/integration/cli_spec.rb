# frozen_string_literal: true

require 'integration_spec_helper'

RSpec.describe "CLI", type: "aruba" do
  let(:models_dir) { 'app/models' }

  before do
    copy(Dir[File.join(aruba.config.root_directory, 'spec/test_app/*')], aruba.config.home_directory)
  end

  context "when running in a non-Rails project directory" do
    before do
      remove('Rakefile') if exist?('Rakefile')
      remove('Gemfile') if exist?('Gemfile')
    end

    let(:error_message) { "Please run annotaterb from the root of the project." }

    it "exits and outputs an error message" do
      run_command("annotaterb")

      expect(last_command_started).to have_exit_status(1)
      expect(last_command_started).to have_output_on_stderr(error_message)
    end
  end

  context "when running in a directory with a Rakefile and a Gemfile" do
    let(:help_banner_fragment) { "Usage: annotaterb [command] [options]" }
    let(:templates_dir) { File.join(aruba.config.root_directory, "spec/templates/#{ENV['DATABASE_ADAPTER']}") }

    it "outputs the help message" do
      run_command("annotaterb")

      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to include(help_banner_fragment)
    end

    it 'annotates files that have not been annotated' do
      expected_test_default = read(File.join(templates_dir, 'test_default.rb'))
      expected_test_null_false = read(File.join(templates_dir, 'test_null_false.rb'))

      original_test_default = read(File.join(models_dir, 'test_default.rb'))
      original_test_null_false = read(File.join(models_dir, 'test_null_false.rb'))

      expect(expected_test_default).not_to eq(original_test_default)
      expect(expected_test_null_false).not_to eq(original_test_null_false)

      run_command('annotaterb models')

      annotated_test_default = read(File.join(models_dir, 'test_default.rb'))
      annotated_test_null_false = read(File.join(models_dir, 'test_null_false.rb'))

      expect(last_command_started).to be_successfully_executed
      expect(expected_test_default).to eq(annotated_test_default)
      expect(expected_test_null_false).to eq(annotated_test_null_false)
    end
  end
end
