# encoding: utf-8

RSpec.describe AnnotateRb::ModelAnnotator::Annotator do
  describe '.parse_options' do
    let(:options) do
      {
        root_dir: '/root',
        model_dir: 'app/models,app/one,  app/two   ,,app/three'
      }
    end

    before do
      described_class.send(:parse_options, options)
    end

    describe '@root_dir' do
      subject do
        described_class.instance_variable_get(:@root_dir)
      end

      it 'sets @root_dir' do
        is_expected.to eq('/root')
      end
    end

    describe '@model_dir' do
      subject do
        described_class.instance_variable_get(:@model_dir)
      end

      it 'separates option "model_dir" with commas and sets @model_dir as an array of string' do
        is_expected.to eq(['app/models', 'app/one', 'app/two', 'app/three'])
      end
    end
  end
end