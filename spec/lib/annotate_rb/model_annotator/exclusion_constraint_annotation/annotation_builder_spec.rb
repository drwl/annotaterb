# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ExclusionConstraintAnnotation::AnnotationBuilder do
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
      mock_connection([], [], [], exclusion_constraints: exclusion_constraints)
    end
    let(:options) { AnnotateRb::Options.new({show_exclusion_constraints: true}) }
    let(:exclusion_constraints) do
      [
        mock_exclusion_constraint("no_overlap", "room_id WITH =, during WITH &&",
          using: :gist,
          where: "canceled = false",
          deferrable: :deferred),
        mock_exclusion_constraint("exclude_period", "period WITH &&", using: :gist),
        mock_exclusion_constraint("plain_exclude", "id WITH =")
      ]
    end

    context "when show_exclusion_constraints option is false" do
      let(:options) { AnnotateRb::Options.new({show_exclusion_constraints: false}) }

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "using default format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Exclusion Constraints
          #
          #  exclude_period  (period WITH &&) USING gist
          #  no_overlap      (room_id WITH =, during WITH &&) USING gist WHERE (canceled = false) DEFERRABLE INITIALLY DEFERRED
          #  plain_exclude   (id WITH =)
        RESULT
      end

      it "annotates the exclusion constraints" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "using markdown format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # ### Exclusion Constraints
          #
          # * `exclude_period`: `(period WITH &&) USING gist`
          # * `no_overlap`: `(room_id WITH =, during WITH &&) USING gist WHERE (canceled = false) DEFERRABLE INITIALLY DEFERRED`
          # * `plain_exclude`: `(id WITH =)`
        RESULT
      end

      it "annotates the exclusion constraints" do
        expect(markdown_format).to eq(expected_result)
      end
    end

    context "when model connection does not support exclusion constraints" do
      let(:connection) do
        mock_connection([], [], [], supports_exclusion_constraints?: false, exclusion_constraints: exclusion_constraints)
      end

      it { expect(default_format).to be_nil }
    end

    context "when exclusion constraints is empty" do
      let(:connection) do
        mock_connection([], [], [], exclusion_constraints: [])
      end

      it { expect(default_format).to be_nil }
    end

    context "using yard format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Exclusion Constraints
          #
          #  exclude_period  (period WITH &&) USING gist
          #  no_overlap      (room_id WITH =, during WITH &&) USING gist WHERE (canceled = false) DEFERRABLE INITIALLY DEFERRED
          #  plain_exclude   (id WITH =)
        RESULT
      end

      it "annotates the exclusion constraints" do
        expect(yard_format).to eq(expected_result)
      end
    end

    context "using rdoc format" do
      let(:expected_result) do
        <<~RESULT.strip
          #
          # Exclusion Constraints
          #
          #  exclude_period  (period WITH &&) USING gist
          #  no_overlap      (room_id WITH =, during WITH &&) USING gist WHERE (canceled = false) DEFERRABLE INITIALLY DEFERRED
          #  plain_exclude   (id WITH =)
        RESULT
      end

      it "annotates the exclusion constraints" do
        expect(rdoc_format).to eq(expected_result)
      end
    end
  end
end
