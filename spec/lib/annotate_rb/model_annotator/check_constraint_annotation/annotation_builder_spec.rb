# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::CheckConstraintAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(model, options).build }
    let(:default_format) { subject.to_default }
    let(:markdown_format) { subject.to_markdown }

    let(:model) do
      instance_double(
        AnnotateRb::ModelAnnotator::ModelWrapper,
        connection: connection,
        table_name: "Foo"
      )
    end
    let(:connection) do
      mock_connection([], [], check_constraints)
    end
    let(:options) { AnnotateRb::Options.new({show_check_constraints: true}) }
    let(:check_constraints) do
      [
        mock_check_constraint("alive", "age < 150"),
        mock_check_constraint("must_be_adult", "age >= 18"),
        mock_check_constraint("missing_expression", nil),
        mock_check_constraint("multiline_test", <<~SQL)
          CASE
            WHEN (age >= 18) THEN (age <= 21)
            ELSE true
          END
        SQL
      ]
    end

    context "when show_check_constraints option is false" do
      let(:options) { AnnotateRb::Options.new({show_check_constraints: false}) }

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "using default format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Check Constraints
          #
          #  alive               (age < 150)
          #  missing_expression
          #  multiline_test      (CASE WHEN (age >= 18) THEN (age <= 21) ELSE true END)
          #  must_be_adult       (age >= 18)
        RESULT
      end

      it "annotates the check constraints" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "using markdown format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # ### Check Constraints
          #
          # * `alive`: `(age < 150)`
          # * `missing_expression`
          # * `multiline_test`: `(CASE WHEN (age >= 18) THEN (age <= 21) ELSE true END)`
          # * `must_be_adult`: `(age >= 18)`
        RESULT
      end

      it "annotates the check constraints" do
        expect(markdown_format).to eq(expected_result)
      end
    end

    context "when model connection does not support check constraints" do
      let(:connection) do
        conn_options = {supports_check_constraints?: false}

        mock_connection([], [], [], conn_options)
      end

      it { expect(default_format).to be_nil }
    end

    context "when check constraints is empty" do
      let(:connection) do
        conn_options = {supports_check_constraints?: true}

        mock_connection([], [], [], conn_options)
      end

      it { expect(default_format).to be_nil }
    end
  end
end
