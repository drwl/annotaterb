# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::UniqueConstraintAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(model, options).build }
    let(:default_format) { subject.to_default }
    let(:markdown_format) { subject.to_markdown }
    let(:yard_format) { subject.to_yard }
    let(:rdoc_format) { subject.to_rdoc }

    let(:model) do
      instance_double(
        AnnotateRb::ModelAnnotator::ModelWrapper,
        connection: connection,
        table_name: "Foo"
      )
    end
    let(:connection) do
      mock_connection([], [], [], unique_constraints: unique_constraints)
    end
    let(:options) { AnnotateRb::Options.new({show_unique_constraints: true}) }
    let(:unique_constraints) do
      [
        mock_unique_constraint("unique_position", ["position"]),
        mock_unique_constraint("unique_sku", ["tenant_id", "sku"]),
        mock_unique_constraint("unique_deferred", ["email"], deferrable: :deferred)
      ]
    end

    context "when show_unique_constraints option is false" do
      let(:options) { AnnotateRb::Options.new({show_unique_constraints: false}) }

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "using default format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Unique Constraints
          #
          #  unique_deferred  (email) DEFERRABLE INITIALLY DEFERRED
          #  unique_position  (position)
          #  unique_sku       (tenant_id, sku)
        RESULT
      end

      it "annotates the unique constraints" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "using markdown format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # ### Unique Constraints
          #
          # * `unique_deferred`: `(email) DEFERRABLE INITIALLY DEFERRED`
          # * `unique_position`: `(position)`
          # * `unique_sku`: `(tenant_id, sku)`
        RESULT
      end

      it "annotates the unique constraints" do
        expect(markdown_format).to eq(expected_result)
      end
    end

    context "when model connection does not support unique constraints" do
      let(:connection) do
        mock_connection([], [], [], supports_unique_constraints?: false, unique_constraints: unique_constraints)
      end

      it { expect(default_format).to be_nil }
    end

    context "when unique constraints is empty" do
      let(:connection) do
        mock_connection([], [], [], unique_constraints: [])
      end

      it { expect(default_format).to be_nil }
    end

    context "using yard format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Unique Constraints
          #
          #  unique_deferred  (email) DEFERRABLE INITIALLY DEFERRED
          #  unique_position  (position)
          #  unique_sku       (tenant_id, sku)
        RESULT
      end

      it "annotates the unique constraints" do
        expect(yard_format).to eq(expected_result)
      end
    end

    context "using rdoc format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Unique Constraints
          #
          #  unique_deferred  (email) DEFERRABLE INITIALLY DEFERRED
          #  unique_position  (position)
          #  unique_sku       (tenant_id, sku)
        RESULT
      end

      it "annotates the unique constraints" do
        expect(rdoc_format).to eq(expected_result)
      end
    end
  end
end
