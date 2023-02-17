# encoding: utf-8
require 'annotate/annotate_models'
require 'annotate/active_record_patch'
require 'active_support/core_ext/string'
require 'files'
require 'tmpdir'

RSpec.describe AnnotateModels do
  describe '.set_defaults' do
    subject do
      Annotate::Helpers.true?(ENV['show_complete_foreign_keys'])
    end

    context 'when default value of "show_complete_foreign_keys" is not set' do
      it 'returns false' do
        is_expected.to be(false)
      end
    end

    context 'when default value of "show_complete_foreign_keys" is set' do
      before do
        Annotate.instance_variable_set('@has_set_defaults', false)
        Annotate.set_defaults('show_complete_foreign_keys' => 'true')
      end

      after do
        Annotate.instance_variable_set('@has_set_defaults', false)
        ENV.delete('show_complete_foreign_keys')
      end

      it 'returns true' do
        is_expected.to be(true)
      end
    end
  end
end
