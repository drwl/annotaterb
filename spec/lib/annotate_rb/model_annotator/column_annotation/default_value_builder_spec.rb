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

    context "when value is a Date" do
      let(:value) { Date.new(2023, 9, 7) }

      it { is_expected.to eq("Thu, 07 Sep 2023") }
    end

    context "when value is a DateTime" do
      let(:value) { DateTime.new(2023, 9, 7) }

      it { is_expected.to eq("Thu, 07 Sep 2023 00:00:00 +0000") }
    end

    context "when value is an Array" do
      context "array is empty" do
        let(:value) { [] }

        it { is_expected.to eq("[]") }
      end

      context "array has a String" do
        let(:value) { ["string"] }

        it { is_expected.to eq("[\"string\"]") }
      end

      context "array has Strings" do
        let(:value) { ["a", "string"] }

        it { is_expected.to eq("[\"a\", \"string\"]") }
      end

      context "array has Numbers" do
        let(:value) { [42, 1.2] }

        it { is_expected.to eq("[42, 1.2]") }
      end

      context "array has BigDecimals" do
        let(:value) { [BigDecimal("0.1"), BigDecimal("0.2")] }

        it { is_expected.to eq("[0.1, 0.2]") }
      end

      context "array has Booleans" do
        let(:value) { [true, false] }

        it { is_expected.to eq("[TRUE, FALSE]") }
      end

      context "when value is a Date" do
        let(:value) { [Date.new(2023, 9, 7)] }

        it { is_expected.to eq("Thu, 07 Sep 2023") }
      end

      context "when value is a DateTime" do
        let(:value) { [DateTime.new(2023, 9, 7)] }

        it { is_expected.to eq("Thu, 07 Sep 2023 00:00:00 +0000") }
      end
    end
  end
end
