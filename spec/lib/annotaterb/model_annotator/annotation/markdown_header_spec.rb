# frozen_string_literal: true

RSpec.describe Annotaterb::ModelAnnotator::Annotation::MarkdownHeader do
  subject { described_class.new(max_size) }
  let(:markdown_format) { subject.to_markdown }
  let(:default_format) { subject.to_default }

  context "using default format" do
    let(:max_size) { 0 }

    it { expect(default_format).to be_nil }
  end

  context "using markdown format" do
    let(:max_size) { 10 }
    let(:expected_header) do
      <<~HEADER.strip
        # ### Columns
        #
        # Name             | Type               | Attributes
        # ---------------- | ------------------ | ---------------------------
      HEADER
    end

    it "matches the expected header" do
      expect(markdown_format).to eq(expected_header)
    end
  end

  context "with a larger max size" do
    let(:max_size) { 20 }
    let(:expected_header) do
      <<~HEADER.strip
        # ### Columns
        #
        # Name                       | Type               | Attributes
        # -------------------------- | ------------------ | ---------------------------
      HEADER
    end

    it "matches the expected header" do
      expect(markdown_format).to eq(expected_header)
    end
  end
end
