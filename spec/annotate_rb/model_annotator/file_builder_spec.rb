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
  end
end
