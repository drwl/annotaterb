# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotatedFile::Updater do
  describe "#update" do
    subject { described_class.new(*params).update }

    let(:params) do
      [
        file_content,
        new_annotations,
        annotation_position,
        parsed_file,
        options
      ]
    end

    let(:annotation_position) { :position_in_class }
    let(:parsed_file) do
      parser_klass = AnnotateRb::ModelAnnotator::FileParser::CustomParser
      AnnotateRb::ModelAnnotator::FileParser::ParsedFile.new(file_content, new_annotations, parser_klass, options).parse
    end

    context "with a foreign key constraint change" do
      let(:file_content) do
        <<~FILE
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
      end
      let(:new_annotations) do
        <<~ANNOTATIONS
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

    context "with an index change containing escaped characters" do
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  foreign_thing_id :integer          not null
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:new_annotations) do
        <<~ANNOTATIONS
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #  foreign_thing_id :integer          not null
          #
          # Indexes
          #
          #  index_rails_02e851e3b8  (another_column) WHERE value IS LIKE '\\\\%'
          #
        ANNOTATIONS
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
          # Indexes
          #
          #  index_rails_02e851e3b8  (another_column) WHERE value IS LIKE '\\\\%'
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
      let(:file_content) do
        <<~FILE
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
      end
      let(:new_annotations) do
        <<~ANNOTATIONS
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATIONS
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
      let(:file_content) do
        <<~FILE
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
      end
      let(:new_annotations) do
        <<~ANNOTATIONS
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATIONS
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

    context "when updating annotations for a FactoryBot factory" do
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #
          FactoryBot.define do
            factory :user do
              admin { false }
            end
          end
        FILE
      end
      let(:new_annotations) do
        <<~ANNOTATIONS
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
          FactoryBot.define do
            factory :user do
              admin { false }
            end
          end
        CONTENT
      end

      it "returns the updated annotated file" do
        is_expected.to eq(expected_content)
      end
    end

    context "when updating annotations for a Fabrication fabricator" do
      let(:file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id               :integer          not null, primary key
          #
          Fabricator(:user) do
            name
            reminder_at { 1.day.from_now.iso8601 }
          end
        FILE
      end
      let(:new_annotations) do
        <<~ANNOTATIONS
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
          Fabricator(:user) do
            name
            reminder_at { 1.day.from_now.iso8601 }
          end
        CONTENT
      end

      it "returns the updated annotated file" do
        is_expected.to eq(expected_content)
      end
    end
  end
end
