# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotationDiffGenerator do
  describe '.call' do
    subject { described_class.call(file_content, annotation_block) }

    context 'when model file does not have any annotations' do
      let(:file_content) do
        <<~FILE
          class User < ApplicationRecord
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

      let(:current_columns) do
        []
      end
      let(:new_columns) do
        [
          "#  id                     :bigint           not null, primary key",
          "# Table name: users"
        ]
      end

      it 'returns an AnnotationDiff object with the expected old and new columns' do
        expect(subject.current_columns).to eq(current_columns)
        expect(subject.new_columns).to eq(new_columns)
        expect(subject.changed?).to eq(true)
      end
    end

    context 'when model files has the latest annotations (does not need to be updated)' do
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ApplicationRecord
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

      let(:current_columns) do
        [
          "#  id                     :bigint           not null, primary key",
          "# Table name: users"
        ]
      end
      let(:new_columns) do
        [
          "#  id                     :bigint           not null, primary key",
          "# Table name: users"
        ]
      end

      it 'returns an AnnotationDiff object with the expected old and new columns' do
        expect(subject.current_columns).to eq(current_columns)
        expect(subject.new_columns).to eq(new_columns)
        expect(subject.changed?).to eq(false)
      end
    end

    xcontext 'when model file has existing annotations with column comments', focus: true do
      let(:annotation_block) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #
        SCHEMA
      end
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                       :integer          not null, primary key
          #  name([sensitivity: low]) :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      let(:current_columns) do
        [
          "#  id                     :bigint           not null, primary key",
          "#  name([sensitivity: low]) :string(50)       not null",
          "# Table name: users"
        ]
      end
      let(:new_columns) do
        [
          "#  id                     :bigint           not null, primary key",
          "#  name([sensitivity: medium]) :string(50)       not null",
          "# Table name: users"
        ]
      end

      it 'returns an AnnotationDiff object with the expected old and new columns' do
        expect(subject.current_columns).to eq(current_columns)
        expect(subject.new_columns).to eq(new_columns)
        expect(subject.changed?).to eq(false)
      end
    end
  end
end
