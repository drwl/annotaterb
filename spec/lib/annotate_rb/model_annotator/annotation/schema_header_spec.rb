# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::Annotation::SchemaHeader do
  describe "#to_default" do
    subject { described_class.new(table_name).to_default }

    let(:table_name) { "users" }
    let(:expected_header) do
      <<~HEADER
        #
        # Table name: users
        #
      HEADER
    end

    it { is_expected.to eq(expected_header) }
  end

  describe "#to_markdown" do
    subject { described_class.new(table_name).to_markdown }

    let(:table_name) { "users" }
    let(:expected_header) do
      <<~HEADER
        #
        # Table name: `users`
        #
      HEADER
    end

    it { is_expected.to eq(expected_header) }
  end
end
