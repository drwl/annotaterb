# encoding: utf-8

RSpec.describe AnnotateRb::ModelAnnotator::Annotator do
  describe '.get_patterns' do
    subject { described_class.get_patterns(options, pattern_type) }

    context 'when pattern_type is "additional_file_patterns"' do
      let(:pattern_type) { 'additional_file_patterns' }

      context 'when additional_file_patterns is specified in the options' do
        let(:additional_file_patterns) do
          [
            '/%PLURALIZED_MODEL_NAME%/**/*.rb',
            '/bar/%PLURALIZED_MODEL_NAME%/*_form'
          ]
        end

        let(:options) { { additional_file_patterns: additional_file_patterns } }

        it 'returns additional_file_patterns in the argument "options"' do
          is_expected.to eq(additional_file_patterns)
        end
      end

      context 'when additional_file_patterns is not specified in the options' do
        let(:options) { {} }

        it 'returns an empty array' do
          is_expected.to eq([])
        end
      end
    end
  end
end
