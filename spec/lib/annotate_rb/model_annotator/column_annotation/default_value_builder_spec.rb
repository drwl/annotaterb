# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnAnnotation::DefaultValueBuilder do
  describe "#build" do
    subject { described_class.new(value).build }

    context "when value is a String" do
      let(:value) { "a random string" }

      it { is_expected.to eq("\"a random string\"") }
    end

    context "when value is nil" do
      let(:value) { nil }

      it { is_expected.to eq("NULL") }
    end

    context "when value is true" do
      let(:value) { true }

      it { is_expected.to eq("TRUE") }
    end

    context "when value is false" do
      let(:value) { false }

      it { is_expected.to eq("FALSE") }
    end

    context "when value is an Integer" do
      let(:value) { 42 }

      it { is_expected.to eq("42") }
    end

    context "when value is an Decimal" do
      let(:value) { 1.2 }

      it { is_expected.to eq("1.2") }
    end

    context "when value is a BigDecimal" do
      let(:value) { BigDecimal("1.2") }

      it { is_expected.to eq("1.2") }
    end

    xcontext "when value is an Array" do
      context "array is empty" do
        let(:value) { [] }

        it { is_expected.to eq("[]") }
      end
    end
  end
end
