# encoding: utf-8

RSpec.describe AnnotateRb::ModelAnnotator::Annotator do
  describe '.set_defaults' do
    subject do
      AnnotateRb::ModelAnnotator::Helper.true?(ENV['show_complete_foreign_keys'])
    end

    context 'when default value of "show_complete_foreign_keys" is not set' do
      it 'returns false' do
        is_expected.to be(false)
      end
    end

    context 'when default value of "show_complete_foreign_keys" is set' do
      before do
        AnnotateRb::OldAnnotate.instance_variable_set('@has_set_defaults', false)
        AnnotateRb::OldAnnotate.set_defaults('show_complete_foreign_keys' => 'true')
      end

      after do
        AnnotateRb::OldAnnotate.instance_variable_set('@has_set_defaults', false)
        ENV.delete('show_complete_foreign_keys')
      end

      it 'returns true' do
        is_expected.to be(true)
      end
    end
  end
end
