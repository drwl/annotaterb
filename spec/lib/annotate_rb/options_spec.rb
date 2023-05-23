# frozen_string_literal: true

RSpec.describe AnnotateRb::Options do
  describe ".from" do
    subject { described_class.from(options, state) }

    let(:options) { {} }
    let(:state) { {} }

    it { is_expected.to be_a(described_class) }
  end

  describe ".load_defaults" do
    subject { described_class.new(options, state).load_defaults }

    let(:key) { :show_complete_foreign_keys }
    let(:state) { {} }

    context 'when default value of "show_complete_foreign_keys" is not set' do
      let(:options) { {} }

      it "returns false" do
        expect(subject[key]).to eq(false)
      end
    end

    context 'when default value of "show_complete_foreign_keys" is set' do
      let(:options) { {key => true} }

      it "returns true" do
        expect(subject[key]).to eq(true)
      end
    end

    describe "path options" do
      context "when model_dir is a string with multiple paths" do
        let(:options) do
          {
            model_dir: "app/models,app/one,  app/two   ,,app/three"
          }
        end

        it 'separates option "model_dir" with commas into an array of strings' do
          expect(subject[:model_dir]).to eq(["app/models", "app/one", "app/two", "app/three"])
        end
      end
    end
  end

  describe "#set_state" do
    let(:instance) { described_class.new(options, state) }
    subject { instance.set_state(key, value, overwrite) }

    let(:options) { {} }
    let(:state) { {} }

    describe "writing a new key value pair" do
      let(:key) { :some_key }
      let(:value) { "some_value" }
      let(:overwrite) { true }

      it "does not raise" do
        expect { subject }.to_not raise_error(ArgumentError)
      end

      it "writes the state successfully" do
        subject
        expect(instance.get_state(key)).to eq(value)
      end
    end

    describe "writing to an existing key" do
      let(:key) { :some_key }
      let(:value) { "some_value" }
      let(:old_value) { "old_value" }
      let(:state) { {key => old_value} }

      context "when overwrite is true" do
        let(:overwrite) { true }

        it "does not raise" do
          expect { subject }.to_not raise_error(ArgumentError)
        end

        it "writes the state successfully" do
          subject
          expect(instance.get_state(key)).to eq(value)
        end
      end

      context "when overwrite is false" do
        let(:overwrite) { false }

        it "raises" do
          expect { subject }.to raise_error(ArgumentError, a_string_including(old_value))
        end
      end
    end
  end
end
