# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotationDiff do
  describe 'attributes' do
    subject { described_class.new(old_columns, new_columns) }
    let(:old_columns) { 'some old columns string' }
    let(:new_columns) { 'some new columns string' }

    it 'returns the old columns' do
      expect(subject.old_columns).to eq(old_columns)
    end

    it 'returns the new columns' do
      expect(subject.new_columns).to eq(new_columns)
    end
  end

  describe '#changed?' do
    subject { described_class.new(old_columns, new_columns).changed? }

    context 'when the old and new columns are the same' do
      let(:old_columns) { 'the same' }
      let(:new_columns) { 'the same' }

      it { is_expected.to eq(false) }
    end

    context 'when the old and new columns are different' do
      let(:old_columns) { 'the old' }
      let(:new_columns) { 'the new' }

      it { is_expected.to eq(true) }
    end
  end
end