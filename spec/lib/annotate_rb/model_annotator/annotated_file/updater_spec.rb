# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotatedFile::Updater do
  describe "#update" do
    subject { described_class.new(*params).update }

    let(:params) do
      [
        file_components,
        annotation_position,
        options
      ]
    end

    let(:annotation_position) { :position_in_class }

    context "with a foreign key constraint change" do
      let(:file_components) do
        file_content = <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  foreign_thing_id :integer          not null
          #
          # Foreign Keys
          #
          #  fk_rails_...  (foreign_thing_id => foreign_things.id) ON DELETE => restrict
          #
          class User < ApplicationRecord
          end
        FILE

        new_annotations = <<~ANNOTATIONS
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  foreign_thing_id :integer          not null
          #
          # Foreign Keys
          #
          #  fk_rails_...  (foreign_thing_id => foreign_things.id) ON DELETE => cascade
          #
        ANNOTATIONS

        AnnotateRb::ModelAnnotator::FileComponents.new(
          file_content,
          new_annotations,
          options
        )
      end

      let(:options) { AnnotateRb::Options.new({position_in_class: "before", show_foreign_keys: true}) }

      let(:expected_content) do
        <<~CONTENT
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  foreign_thing_id :integer          not null
          #
          # Foreign Keys
          #
          #  fk_rails_...  (foreign_thing_id => foreign_things.id) ON DELETE => cascade
          #
          class User < ApplicationRecord
          end
        CONTENT
      end

      it "returns the updated annotated file" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "after" for the existing annotation but position is "before" for the new annotation' do
      let(:file_components) do
        file_content = <<~FILE
          class User < ApplicationRecord
          end

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        FILE

        new_annotations = <<~ANNOTATIONS
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATIONS

        AnnotateRb::ModelAnnotator::FileComponents.new(
          file_content,
          new_annotations,
          options
        )
      end

      let(:options) { AnnotateRb::Options.new({position_in_class: "before"}) }

      let(:expected_content) do
        <<~CONTENT
          class User < ApplicationRecord
          end

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        CONTENT
      end

      it "returns the updated annotated file content but retains the original file position" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "before" for the existing annotation but "after" for the new annotation' do
      let(:file_components) do
        file_content = <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE

        new_annotations = <<~ANNOTATIONS
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATIONS

        AnnotateRb::ModelAnnotator::FileComponents.new(
          file_content,
          new_annotations,
          options
        )
      end

      let(:options) { AnnotateRb::Options.new({position_in_class: "after"}) }

      let(:expected_content) do
        <<~CONTENT
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ApplicationRecord
          end
        CONTENT
      end

      it "returns the updated annotated file content but retains the original file position" do
        is_expected.to eq(expected_content)
      end
    end
  end
end
