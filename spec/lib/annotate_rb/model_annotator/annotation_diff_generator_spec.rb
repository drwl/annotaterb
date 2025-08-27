# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotationDiffGenerator do
  def test_columns_match_expected
    remove_whitespace = proc { |str| str.delete(" \t\r\n") }

    resulting_current_columns_data = subject.current_columns.map(&remove_whitespace)
    expected_current_columns_data = current_columns.map(&remove_whitespace)
    resulting_new_columns_data = subject.new_columns.map(&remove_whitespace)
    expected_new_columns_data = new_columns.map(&remove_whitespace)

    expect(resulting_current_columns_data).to eq(expected_current_columns_data)
    expect(resulting_new_columns_data).to eq(expected_new_columns_data)
  end

  describe ".call" do
    subject { described_class.call(file_content, annotation_block) }

    context "when model file does not have any annotations" do
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

      it "returns an AnnotationDiff object with the expected old and new columns" do
        test_columns_match_expected

        expect(subject.changed?).to eq(true)
      end
    end

    context "when model files has the latest annotations (does not need to be updated)" do
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

      it "returns an AnnotationDiff object with the expected old and new columns" do
        test_columns_match_expected

        expect(subject.changed?).to eq(false)
      end
    end

    context "when model file has existing annotations with column comments" do
      let(:annotation_block) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :bigint           not null, primary key
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
          #  id                       :bigint           not null, primary key
          #  name([sensitivity: low]) :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      let(:current_columns) do
        [
          "#  id                       :bigint           not null, primary key",
          "#  name([sensitivity: low]) :string(50)       not null",
          "# Table name: users"
        ]
      end
      let(:new_columns) do
        [
          "#  id                          :bigint           not null, primary key",
          "#  name([sensitivity: medium]) :string(50)       not null",
          "# Table name: users"
        ]
      end

      it "returns an AnnotationDiff object with the expected old and new columns" do
        test_columns_match_expected

        expect(subject.changed?).to eq(true)
      end
    end

    context "when a new column with metadata in parentheses is added" do
      let(:annotation_block) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                               :bigint           not null, primary key
          #  name([sensitivity: medium])      :string(50)       not null
          #  status(active/pending/inactive)  :string           not null
          #
        SCHEMA
      end
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                               :bigint           not null, primary key
          #  name([sensitivity: medium])      :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      let(:current_columns) do
        [
          "#  id                               :bigint           not null, primary key",
          "#  name([sensitivity: medium])      :string(50)       not null",
          "# Table name: users"
        ]
      end
      let(:new_columns) do
        [
          "#  id                               :bigint           not null, primary key",
          "#  name([sensitivity: medium])      :string(50)       not null",
          "#  status(active/pending/inactive)  :string           not null",
          "# Table name: users"
        ]
      end

      it "returns an AnnotationDiff object with the expected old and new columns" do
        test_columns_match_expected

        expect(subject.changed?).to eq(true)
      end
    end

    context "when column comments contain Japanese characters" do
      let(:annotation_block) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name(名前)              :string(50)       not null
          #  email(メールアドレス)    :string(255)      not null
          #  created_at(作成日時)     :datetime         not null
          #
        SCHEMA
      end
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name(名前)              :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      let(:current_columns) do
        [
          "#  id                     :bigint           not null, primary key",
          "#  name(名前)              :string(50)       not null",
          "# Table name: users"
        ]
      end
      let(:new_columns) do
        [
          "#  created_at(作成日時)     :datetime         not null",
          "#  email(メールアドレス)    :string(255)      not null",
          "#  id                     :bigint           not null, primary key",
          "#  name(名前)              :string(50)       not null",
          "# Table name: users"
        ]
      end

      it "returns an AnnotationDiff object with the expected old and new columns" do
        test_columns_match_expected

        expect(subject.changed?).to eq(true)
      end
    end
  end
end
