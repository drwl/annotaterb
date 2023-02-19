# encoding: utf-8

RSpec.describe AnnotateRb::ModelAnnotator::Annotator do
  describe '.annotate_model_file' do
    before do
      class Foo < ActiveRecord::Base; end
      allow(described_class).to receive(:get_model_class).with('foo.rb') { Foo }
      allow(Foo).to receive(:table_exists?) { false }
    end

    subject do
      described_class.annotate_model_file([], 'foo.rb', nil, {})
    end

    after { Object.send :remove_const, 'Foo' }

    it 'skips attempt to annotate if no table exists for model' do
      is_expected.to eq nil
    end

    context 'with a non-class' do
      before do
        NotAClass = 'foo'.freeze # rubocop:disable Naming/ConstantName
        allow(described_class).to receive(:get_model_class).with('foo.rb') { NotAClass }
      end

      after { Object.send :remove_const, 'NotAClass' }

      it "doesn't output an error" do
        expect { subject }.not_to output.to_stderr
      end
    end
  end
end
