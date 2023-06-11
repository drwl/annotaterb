# frozen_string_literal: true

RSpec.describe "CLI", type: "aruba" do
  context "when running in a non-Rails project directory" do
    before do
      # Assumes there's no Rakefile or Gemfile
      run_command("annotaterb")
    end

    let(:error_message) { "Please run annotaterb from the root of the project." }

    it do
      expect(last_command_started).to have_exit_status(1)
      expect(last_command_started).to have_output_on_stderr(error_message)
    end
  end
end
