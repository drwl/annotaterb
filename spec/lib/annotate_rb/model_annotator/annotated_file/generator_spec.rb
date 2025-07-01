# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::AnnotatedFile::Generator do
  describe "#generate" do
    subject { described_class.new(*params).generate }

    let(:params) do
      [
        file_content,
        new_annotations,
        annotation_position,
        parser_klass,
        parsed_file,
        options
      ]
    end

    let(:file_content) do
      <<~FILE
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
    let(:annotation_position) { :position_in_class }
    let(:parser_klass) { AnnotateRb::ModelAnnotator::FileParser::CustomParser }
    let(:parsed_file) do
      AnnotateRb::ModelAnnotator::FileParser::ParsedFile.new(file_content, new_annotations, parser_klass, options).parse
    end

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

      let(:file_content) do
        <<~FILE
          #{magic_comment}
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
        let(:file_content) do
          <<~FILE
            #{magic_comment}



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

        it "only preserves the empty linebreaks before the annotation" do
          is_expected.to eq(expected_content)
        end
      end

      context 'when there are multiple line breaks between magic comment and the annotation with position is "after"' do
        let(:file_content) do
          <<~FILE
            #{magic_comment}


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

    context 'when position is "before" for a FactoryBot factory' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "before"}) }

      let(:file_content) do
        <<~FILE
          FactoryBot.define do
            factory :user do
              admin { false }
            end
          end
        FILE
      end

      let(:expected_content) do
        <<~CONTENT
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          FactoryBot.define do
            factory :user do
              admin { false }
            end
          end
        CONTENT
      end

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "after" for a FactoryBot factory' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "after"}) }

      let(:file_content) do
        <<~FILE
          FactoryBot.define do
            factory :user do
              admin { false }
            end
          end
        FILE
      end

      let(:expected_content) do
        <<~CONTENT
          FactoryBot.define do
            factory :user do
              admin { false }
            end
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

    context 'when position is "before" for a Fabrication fabricator' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "before"}) }

      let(:file_content) do
        <<~FILE
          Fabricator(:user) do
            name
            reminder_at { 1.day.from_now.iso8601 }
          end
        FILE
      end

      let(:expected_content) do
        <<~CONTENT
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          Fabricator(:user) do
            name
            reminder_at { 1.day.from_now.iso8601 }
          end
        CONTENT
      end

      it "returns the annotated file content" do
        is_expected.to eq(expected_content)
      end
    end

    context 'when position is "after" for a Fabrication fabricator' do
      let(:options) { AnnotateRb::Options.new({position_in_class: "after"}) }

      let(:file_content) do
        <<~FILE
          Fabricator(:user) do
            name
            reminder_at { 1.day.from_now.iso8601 }
          end
        FILE
      end

      let(:expected_content) do
        <<~CONTENT
          Fabricator(:user) do
            name
            reminder_at { 1.day.from_now.iso8601 }
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

    context "when nested_position option is enabled" do
      context 'with position "before" and nested classes' do
        let(:file_content) do
          <<~FILE
            # frozen_string_literal: true

            module Collapsed
              class TestModel < ApplicationRecord
                def self.table_name_prefix
                  "collapsed_"
                end
              end
            end
          FILE
        end

        let(:options) { AnnotateRb::Options.new({position_in_class: "before", nested_position: true}) }

        let(:expected_content) do
          <<~CONTENT
            # frozen_string_literal: true

            module Collapsed
              # == Schema Information
              #
              # Table name: users
              #
              #  id                     :bigint           not null, primary key
              #
              class TestModel < ApplicationRecord
                def self.table_name_prefix
                  "collapsed_"
                end
              end
            end
          CONTENT
        end

        it "places annotation before the nested class, not at the file top" do
          is_expected.to eq(expected_content)
        end
      end

      context 'with position "before" and no nested_position option (default behavior)' do
        let(:file_content) do
          <<~FILE
            # frozen_string_literal: true

            module Collapsed
              class TestModel < ApplicationRecord
                def self.table_name_prefix
                  "collapsed_"
                end
              end
            end
          FILE
        end

        let(:options) { AnnotateRb::Options.new({position_in_class: "before", nested_position: false}) }

        let(:expected_content) do
          <<~CONTENT
            # frozen_string_literal: true

            # == Schema Information
            #
            # Table name: users
            #
            #  id                     :bigint           not null, primary key
            #
            module Collapsed
              class TestModel < ApplicationRecord
                def self.table_name_prefix
                  "collapsed_"
                end
              end
            end
          CONTENT
        end

        it "places annotation at file top (before the module)" do
          is_expected.to eq(expected_content)
        end
      end

      context "with deeply nested classes" do
        let(:file_content) do
          <<~FILE
            module Level1
              module Level2
                module Level3
                  class DeeplyNestedModel < ApplicationRecord
                  end
                end
              end
            end
          FILE
        end

        let(:options) { AnnotateRb::Options.new({position_in_class: "before", nested_position: true}) }

        let(:expected_content) do
          <<~CONTENT
            module Level1
              module Level2
                module Level3
                  # == Schema Information
                  #
                  # Table name: users
                  #
                  #  id                     :bigint           not null, primary key
                  #
                  class DeeplyNestedModel < ApplicationRecord
                  end
                end
              end
            end
          CONTENT
        end

        it "places annotation before the most deeply nested class" do
          is_expected.to eq(expected_content)
        end
      end

      context "with multiple classes in the same file" do
        let(:file_content) do
          <<~FILE
            module Namespace
              class FirstModel < ApplicationRecord
              end

              class SecondModel < ApplicationRecord
              end
            end
          FILE
        end

        let(:options) { AnnotateRb::Options.new({position_in_class: "before", nested_position: true}) }

        let(:expected_content) do
          <<~CONTENT
            module Namespace
              class FirstModel < ApplicationRecord
              end

              # == Schema Information
              #
              # Table name: users
              #
              #  id                     :bigint           not null, primary key
              #
              class SecondModel < ApplicationRecord
              end
            end
          CONTENT
        end

        it "places annotation before the last class in the file" do
          is_expected.to eq(expected_content)
        end
      end

      context "with nested_position but no classes (only modules)" do
        let(:file_content) do
          <<~FILE
            module OnlyModule
              module AnotherModule
                # Just modules, no classes
              end
            end
          FILE
        end

        let(:options) { AnnotateRb::Options.new({position_in_class: "before", nested_position: true}) }

        let(:expected_content) do
          <<~CONTENT
            # == Schema Information
            #
            # Table name: users
            #
            #  id                     :bigint           not null, primary key
            #
            module OnlyModule
              module AnotherModule
                # Just modules, no classes
              end
            end
          CONTENT
        end

        it "falls back to placing annotation at file top when no classes are found" do
          is_expected.to eq(expected_content)
        end
      end
    end
  end
end
