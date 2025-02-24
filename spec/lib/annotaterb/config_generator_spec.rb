# frozen_string_literal: true

RSpec.describe AnnotateRb::ConfigGenerator do
  describe "#default_config_yml" do
    subject { described_class.default_config_yml }

    let(:example_config_pair) { {models: true} }

    it "returns yml containing defaults" do
      expect(subject).to be_a(String)

      # Might be a better way to do this
      parsed = YAML.safe_load(
        subject, permitted_classes: [Regexp, Symbol], aliases: true, symbolize_names: true
      )

      expect(parsed).to include(**example_config_pair)
    end
  end
end
