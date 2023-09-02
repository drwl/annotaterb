# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnAnnotation::ColumnWrapper do
  include AnnotateTestHelpers

  describe "#default_string" do
    subject { described_class.new(column, column_defaults).default_string }
    let(:column) { mock_column("field", nil, default: value) }
    let(:column_defaults) { {"field" => value} }

    context "when the value is nil" do
      let(:value) { nil }
      it 'returns string "NULL"' do
        is_expected.to eq("NULL")
      end
    end

    context "when the value is true" do
      let(:value) { true }
      it 'returns string "TRUE"' do
        is_expected.to eq("TRUE")
      end
    end

    context "when the value is false" do
      let(:value) { false }
      it 'returns string "FALSE"' do
        is_expected.to eq("FALSE")
      end
    end

    context "when the value is an integer" do
      let(:value) { 25 }
      it "returns the integer as a string" do
        is_expected.to eq("25")
      end
    end

    context "when the value is a float number" do
      context "when the value is like 25.6" do
        let(:value) { 25.6 }
        it "returns the float number as a string" do
          is_expected.to eq("25.6")
        end
      end

      context "when the value is like 1e-20" do
        let(:value) { 1e-20 }
        it "returns the float number as a string" do
          is_expected.to eq("1.0e-20")
        end
      end
    end

    context "when the value is a BigDecimal number" do
      let(:value) { BigDecimal("1.2") }
      it "returns the float number as a string" do
        is_expected.to eq("1.2")
      end
    end

    context "when the value is an array" do
      let(:value) { [BigDecimal("1.2")] }
      it "returns an array of which elements are converted to string" do
        is_expected.to eq(["1.2"])
      end
    end

    context "when the value is a string" do
      let(:value) { "some_string" }
      it "returns the string as is" do
        is_expected.to eq(value)
      end
    end

    context "when the value is an array of strings" do
      let(:value) { ["newsletter"] }
      it "returns an array of strings unescaped" do
        is_expected.to eq(value)
      end
    end
  end
end
