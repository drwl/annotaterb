# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::Annotation::AnnotationBuilder::MainHeader do
  describe "#to_default" do
    subject { described_class.new(version, include_version).to_default }

    let(:version) { 0 }
    let(:include_version) { false }
    let(:expected_header) { "# == Schema Information" }

    it { is_expected.to eq(expected_header) }

    context "when version is non-zero and include version is true" do
      let(:version) { 100 }
      let(:include_version) { true }
      let(:expected_header) { "# == Schema Information\n# Schema version: 100" }

      it { is_expected.to eq(expected_header) }
    end

    context "when version is non-zero and include version is false" do
      let(:version) { 100 }
      let(:include_version) { false }

      it { is_expected.to eq(expected_header) }
    end

    context "when version is zero and include version is true" do
      let(:version) { 0 }
      let(:include_version) { true }

      it { is_expected.to eq(expected_header) }
    end
  end

  describe "#to_markdown" do
    subject { described_class.new(version, include_version).to_markdown }

    let(:version) { 0 }
    let(:include_version) { false }
    let(:expected_header) { "# ## Schema Information" }

    it { is_expected.to eq(expected_header) }

    context "when version is non-zero and include version is true" do
      let(:version) { 100 }
      let(:include_version) { true }
      let(:expected_header) { "# ## Schema Information\n# Schema version: 100" }

      it { is_expected.to eq(expected_header) }
    end

    context "when version is non-zero and include version is false" do
      let(:version) { 100 }
      let(:include_version) { false }

      it { is_expected.to eq(expected_header) }
    end

    context "when version is zero and include version is true" do
      let(:version) { 0 }
      let(:include_version) { true }

      it { is_expected.to eq(expected_header) }
    end
  end
end
