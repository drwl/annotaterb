# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotationDiffGenerator do
  describe '.call' do
    subject { described_class.call(file_content, annotation_block) }

    context 'when model file does not have any annotations' do
      let(:file_content) do
        <<~FILE
          class User < ActiveRecord::Base
          end
        FILE
      end
      let(:annotation_block) do
        <<~ANNOTATION
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATION
      end

      let(:old_columns) { [] }
      let(:new_columns) { ["#  id                     :bigint           not null, primary key", "# Table name: users"] }

      it 'returns an AnnotationDiff object with the expected old and new columns' do
        expect(subject.old_columns).to eq(old_columns)
        expect(subject.new_columns).to eq(new_columns)
      end
    end
  end
end
