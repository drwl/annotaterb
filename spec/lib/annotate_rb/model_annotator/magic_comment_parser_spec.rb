# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::MagicCommentParser do
  describe '.call' do
    subject { described_class.call(content) }

    context 'model file without any magic comments' do
      let(:content) do
        <<~FILE
          class User < ApplicationRecord
          end
        FILE
      end

      it { is_expected.to be_blank }
    end
  end
end