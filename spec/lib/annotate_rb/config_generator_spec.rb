# frozen_string_literal: true

RSpec.describe AnnotateRb::ConfigGenerator do
  describe "#generate_using_defaults" do
    let(:klass) { described_class.new }
    subject { klass.generate_using_defaults }

    it "creates a config dotfile", :isolated_environment do
      expect { subject }.to change { klass.config_file_exists? }.from(false).to(true)
    end
  end
end
