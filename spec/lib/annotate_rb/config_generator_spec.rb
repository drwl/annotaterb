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

  describe "#unset_config_defaults" do
    subject { described_class.unset_config_defaults }

    context "when user config has missing keys" do
      before do
        allow(AnnotateRb::ConfigLoader).to receive(:load_config).and_return({models: true})
      end

      it "returns yaml with missing defaults" do
        expect(subject).to be_a(String)
        expect(subject).not_to be_empty
        expect(subject).not_to include("{}")
      end
    end

    context "when user config has all default keys" do
      before do
        complete_config = AnnotateRb::Options.from({}, {}).to_h
        allow(AnnotateRb::ConfigLoader).to receive(:load_config).and_return(complete_config)
      end

      it "returns empty string instead of empty hash" do
        expect(subject).to eq("")
        expect(subject).not_to include("{}")
      end
    end
  end
end
