# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::CheckConstraintAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(model, options).build }

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
    let(:options) { AnnotateRb::Options.new }
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

    let(:expected_result) do
      <<~RESULT
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
      is_expected.to eq(expected_result)
    end

    context "when model connection does not support check constraints" do
      let(:connection) do
        conn_options = {supports_check_constraints?: false}

        mock_connection([], [], [], conn_options)
      end

      it { is_expected.to be_empty }
    end

    context "when check constraints is empty" do
      let(:connection) do
        conn_options = {supports_check_constraints?: true}

        mock_connection([], [], [], conn_options)
      end

      it { is_expected.to be_empty }
    end

    context "when there are check constraints using markdown" do
      let(:options) { AnnotateRb::Options.new({format_markdown: true}) }
      let(:expected_result) do
        <<~RESULT
          #
          # ### Check Constraints
          #
          # * `alive`: `(age < 150)`
          # * `missing_expression`
          # * `multiline_test`: `(CASE WHEN (age >= 18) THEN (age <= 21) ELSE true END)`
          # * `must_be_adult`: `(age >= 18)`
        RESULT
      end

      it { is_expected.to eq(expected_result) }
    end

    context "when it is just the header using markdown" do
      let(:options) { AnnotateRb::Options.new({format_markdown: true}) }
      let(:connection) do
        mock_connection([], [], [])
      end

      it { is_expected.to be_empty }
    end
  end
end
