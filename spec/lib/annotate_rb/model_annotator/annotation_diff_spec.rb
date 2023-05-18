# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotationDiff do
  describe 'attributes' do
    subject { described_class.new(current_columns, new_columns) }
    let(:current_columns) { 'some current columns string' }
    let(:new_columns) { 'some new columns string' }

    it 'returns the current columns' do
      expect(subject.current_columns).to eq(current_columns)
    end

    it 'returns the new columns' do
      expect(subject.new_columns).to eq(new_columns)
    end
  end

  describe '#changed?' do
    subject { described_class.new(current_columns, new_columns).changed? }

    context 'when the current and new columns are the same' do
      let(:current_columns) { 'the same' }
      let(:new_columns) { 'the same' }

      it { is_expected.to eq(false) }
    end

    context 'when the current and new columns are different' do
      let(:current_columns) { 'the current' }
      let(:new_columns) { 'the new' }

      it { is_expected.to eq(true) }
    end
  end
end