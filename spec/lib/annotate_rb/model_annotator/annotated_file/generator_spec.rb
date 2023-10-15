# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotatedFile::Generator do
  describe "#generate" do
    subject { described_class.new(*params).generate }

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

    context "when file has magic comments" do
      let(:magic_comment) { "# encoding: UTF-8" }

      let(:file_components) do
        file_content = <<~FILE
          #{magic_comment}
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

      let(:options) { AnnotateRb::Options.new({position_in_class: "before"}) }

      let(:expected_content) do
        <<~CONTENT
          #{magic_comment}

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

      it "returns the annotated file content with an empty line between magic comment and annotation" do
        is_expected.to eq(expected_content)
      end

      context "when there are multiple line breaks between magic comment and the annotation" do
        let(:file_components) do
          file_content = <<~FILE
            #{magic_comment}



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

        it "only keeps a single empty line around the annotation" do
          is_expected.to eq(expected_content)
        end
      end

      context 'when there are multiple line breaks between magic comment and the annotation with position is "after"' do
        let(:file_components) do
          file_content = <<~FILE
            #{magic_comment}


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
            #{magic_comment}


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

        it "does not change whitespace between magic comments and model file content" do
          is_expected.to eq(expected_content)
        end
      end
    end
  end
end
