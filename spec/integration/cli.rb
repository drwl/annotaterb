# frozen_string_literal: true

RSpec.describe "CLI", type: "aruba" do
  context "when running in a non-Rails project directory" do
    before do
      # Assumes there's no Rakefile or Gemfile
      run_command("annotaterb")
    end

    let(:error_message) { "Please run annotaterb from the root of the project." }

    it "exits and outputs an error message" do
      expect(last_command_started).to have_exit_status(1)
      expect(last_command_started).to have_output_on_stderr(error_message)
    end
  end

  context "when running in a directory with a Rakefile and a Gemfile" do
    before do
      touch("Rakefile", "Gemfile")
      run_command("annotaterb")
    end

    let(:help_banner_fragment) { "Usage: annotaterb [command] [options]" }

    it "outputs the help message" do
      expect(last_command_started).to be_successfully_executed
      expect(last_command_started.stdout).to include(help_banner_fragment)
    end
  end
end
