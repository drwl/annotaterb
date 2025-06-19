# frozen_string_literal: true

RSpec.describe AnnotateRb::ConfigFinder do
  describe ".find_project_dotfile" do
    subject { described_class.find_project_dotfile }

    context "when the config path directory is set" do
      before {
        allow(File).to receive(:exist?).and_return(true)
        described_class.config_path = "spec/fixtures/.annotaterb.yml"
      }
      after { described_class.config_path = nil }

      it "returns the config path" do
        expect(subject).to eq("spec/fixtures/.annotaterb.yml")
      end
    end

    context "when the config path directory is not set" do
      before { allow(File).to receive(:exist?).and_return(true) }

      it "returns the default dotfile path" do
        expect(subject).to eq(File.expand_path(".annotaterb.yml", Dir.pwd))
      end
    end

    context "when the config path directory is not set and the dotfile does not exist" do
      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
