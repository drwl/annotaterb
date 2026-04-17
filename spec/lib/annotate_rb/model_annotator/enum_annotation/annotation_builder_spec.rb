# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::EnumAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(model, options).build }
    let(:default_format) { subject.to_default }
    let(:markdown_format) { subject.to_markdown }

    let(:model) do
      instance_double(
        AnnotateRb::ModelAnnotator::ModelWrapper,
        enum_types: enum_types,
        table_name: "Foo",
        columns: columns
      )
    end
    let(:columns) do
      [
        mock_column("billing_method", :enum, sql_type: "billing_method"),
        mock_column("status", :enum, sql_type: "order_status"),
        mock_column("name", :string, sql_type: "character varying")
      ]
    end
    let(:enum_types) do
      [
        ["billing_method", ["agency_bill", "direct_bill_to_insured"]],
        ["order_status", ["pending", "shipped", "delivered"]],
        ["unused_enum", ["a", "b"]]
      ]
    end
    let(:options) { AnnotateRb::Options.new({show_enums: true}) }

    context "when show_enums option is false" do
      let(:options) { AnnotateRb::Options.new({show_enums: false}) }
      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "when enum_types is empty" do
      let(:enum_types) { [] }
      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "when table has no enum columns" do
      let(:columns) do
        [
          mock_column("name", :string, sql_type: "character varying"),
          mock_column("age", :integer, sql_type: "integer")
        ]
      end

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "using default format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Enums
          #
          #  billing_method  agency_bill, direct_bill_to_insured
          #  order_status    pending, shipped, delivered
        RESULT
      end

      it "annotates the enum types" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "using markdown format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # ### Enums
          #
          # * `billing_method`: `agency_bill, direct_bill_to_insured`
          # * `order_status`: `pending, shipped, delivered`
        RESULT
      end

      it "annotates the enum types" do
        expect(markdown_format).to eq(expected_result)
      end
    end
  end
end
