# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnTypeBuilder do
  include AnnotateTestHelpers

  describe '#build' do
    subject { described_class.new(column, options).build }

    let(:column) { }
    let(:options) { AnnotateRb::Options.from({}) }

    context 'with an integer column' do
      let(:column) { mock_column(:id, :integer) }
      let(:expected_result) { 'integer' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a string column with a limit' do
      let(:column) { mock_column(:name, :string, limit: 50) }
      let(:expected_result) { 'string(50)' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a text column with a limit' do
      let(:column) { mock_column(:notes, :text, limit: 55) }
      let(:expected_result) { 'text(55)' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a enum column' do
      let(:column) { mock_column(:name, :enum, limit: [:enum1, :enum2]) }
      let(:expected_result) { 'enum' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a decimal column' do
      let(:column) { mock_column(:decimal, :decimal, unsigned?: true, precision: 10, scale: 2) }
      let(:expected_result) { 'decimal(10, 2)' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a float column' do
      let(:column) { mock_column(:float,   :float,   unsigned?: true) }
      let(:expected_result) { 'float' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a bigint column' do
      let(:column) { mock_column(:bigint,  :integer, unsigned?: true, bigint?: true) }
      let(:expected_result) { 'bigint' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a string column with a limit' do
      let(:column) { mock_column(:name, :enum, limit: [:enum1, :enum2]) }
      let(:expected_result) { 'enum' }

      it { is_expected.to eq(expected_result) }
    end

    context 'with a boolean' do
      let(:column) { mock_column(:flag, :boolean, default: false) }
      let(:expected_result) { 'boolean' }

      it { is_expected.to eq(expected_result) }
    end
  end
end
