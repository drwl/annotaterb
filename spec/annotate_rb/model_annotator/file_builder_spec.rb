# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileBuilder do
  describe "#generate_content_with_new_annotations" do
    subject { described_class.new(*params).generate_content_with_new_annotations }

    let(:params) do
      [
        file_components,
        annotation_position,
        options
      ]
    end

    let(:file_components) do
      file_content = <<~FILE
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
    let(:annotation_position) { :position_in_class }

    context 'when position is "before"' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "before"}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when position is :before" do
      let(:options) { AnnotateRb::Options.new({position_in_class: :before}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "top"' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "top"}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when position is :top" do
      let(:options) { AnnotateRb::Options.new({position_in_class: :top}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "after"' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "after"}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when position is :after" do
      let(:options) { AnnotateRb::Options.new({position_in_class: :after}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "bottom"' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "bottom"}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when position is :bottom" do
      let(:options) { AnnotateRb::Options.new({position_in_class: :bottom}) }

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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when the :wrapper_open option is specified" do
      let(:options) { AnnotateRb::Options.new({position_in_class: "before", wrapper_open: "START"}) }

      let(:expected_content) do
        <<~CONTENT
          # START
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

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when the :wrapper_close option is specified" do
      let(:options) { AnnotateRb::Options.new({position_in_class: "before", wrapper_close: "END"}) }

      let(:expected_content) do
        <<~CONTENT
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
          class User < ApplicationRecord
          end
        CONTENT
      end

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context "when both :wrapper_open and :wrapper_close are specified" do
      let(:options) { AnnotateRb::Options.new({position_in_class: "before", wrapper_open: "START", wrapper_close: "END"}) }

      let(:expected_content) do
        <<~CONTENT
          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
          class User < ApplicationRecord
          end
        CONTENT
      end

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end
  end

  describe "#update_existing_annotations" do
    subject { described_class.new(*params).update_existing_annotations }

    let(:params) do
      [
        file_components,
        annotation_position,
        options
      ]
    end

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
    let(:annotation_position) { :position_in_class }

    context "with a foreign key constraint change" do
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
  end
end
