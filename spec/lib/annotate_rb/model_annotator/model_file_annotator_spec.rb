# encoding: utf-8

RSpec.describe AnnotateRb::ModelAnnotator::ModelFileAnnotator do
  describe '.call' do
    subject do
      described_class.call([], 'some_foo.rb', options)
    end

    let(:options) { AnnotateRb::Options.from({ ignore_unknown_models: true }) }

    before do
      $stdout = StringIO.new
      $stderr = StringIO.new
    end

    after do
      $stdout = STDOUT
      $stderr = STDERR
    end

    context 'with a class' do
      let(:some_foo_class) do
        Class.new(ActiveRecord::Base)
      end

      before do
        allow(AnnotateRb::ModelAnnotator::ModelFilesGetter).to receive(:call).with('some_foo.rb', options) { some_foo_class }
        allow(some_foo_class).to receive(:table_exists?) { false }
      end

      it 'skips attempt to annotate if no table exists for model' do
        expect(subject).to eq(nil)
        expect($stderr.string).not_to include('Unable to annotate')
      end
    end

    context 'with a non-class' do
      before do
        stub_const('NotAClass', 'foo')
        allow(AnnotateRb::ModelAnnotator::ModelFilesGetter).to receive(:call).with('some_foo.rb', options) { NotAClass }
      end

      it "doesn't output an error" do
        subject
        expect($stderr.string).not_to include('Unable to annotate')
      end
    end
  end
end
