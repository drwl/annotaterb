# frozen_string_literal: true

RSpec.describe AnnotateRb::Options do
  describe '#set_state' do
    let(:instance) { described_class.new(options, state) }
    subject { instance.set_state(key, value, overwrite) }

    let(:options) { {} }
    let(:state) { {} }

    describe 'writing a new key value pair' do
      let(:key) { :some_key }
      let(:value) { 'some_value' }
      let(:overwrite) { true }

      it 'does not raise' do
        expect { subject }.to_not raise_error(ArgumentError)
      end

      it 'writes the state successfully' do
        subject
        expect(instance.get_state(key)).to eq(value)
      end
    end

    describe 'writing to an existing key' do
      let(:key) { :some_key }
      let(:value) { 'some_value' }
      let(:old_value) { 'old_value' }
      let(:state) { { key => old_value } }

      context 'when overwrite is true' do
        let(:overwrite) { true }

        it 'does not raise' do
          expect { subject }.to_not raise_error(ArgumentError)
        end

        it 'writes the state successfully' do
          subject
          expect(instance.get_state(key)).to eq(value)
        end
      end

      context 'when overwrite is false' do
        let(:overwrite) { false }

        it 'raises' do
          expect { subject }.to raise_error(ArgumentError, a_string_including(old_value))
        end
      end
    end
  end
end
