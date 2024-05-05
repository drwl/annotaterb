# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::AnnotationFinder do
  describe "#run" do
    subject { described_class.new(content, wrapper_open, wrapper_close, parser) }
    let(:parser) { AnnotateRb::ModelAnnotator::FileParser::CustomParser.parse(content) }
    let(:wrapper_open) { nil }
    let(:wrapper_close) { nil }

    shared_examples "finds and extracts the annotation" do
      it "finds the annotation and returns the correct annotation line numbers" do
        subject.run

        expect(subject.annotation_start).to eq(annotation_start)
        expect(subject.annotation_end).to eq(annotation_end)
      end

      it "expects to match annotation" do
        subject.run

        expect(subject.annotation).to eq(annotation)
      end
    end

    context "without annotations" do
      let(:content) do
        <<~FILE
          # typed: strong

          class User < ApplicationRecord
          end
        FILE
      end

      it "raises NoAnnotationFound" do
        expect { subject.run }.to raise_error(described_class::NoAnnotationFound)
      end
    end

    context "with annotations" do
      let(:content) do
        <<~FILE
          # typed: strong

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
      let(:annotation_start) { 2 }
      let(:annotation_end) { 7 }
      let(:annotation) do
        <<~ANNOTATION
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with just the annotation header" do
      let(:content) do
        <<~FILE
          # typed: strong

          # == Schema Information
          class User < ApplicationRecord
          end
        FILE
      end

      it "throws an errors" do
        expect { subject.run }.to raise_error(described_class::MalformedAnnotation)
      end
    end

    context "with annotations and human comment separated by a line break" do
      let(:content) do
        <<~FILE
          # typed: strong

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #

          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 7 }
      let(:annotation) do
        <<~ANNOTATION
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with annotations and human comment joined together" do
      let(:content) do
        <<~FILE
          # typed: strong

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 7 }
      let(:annotation) do
        <<~ANNOTATION
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with annotations using wrapper_open and wrapper_close" do
      let(:wrapper_open) { "START" }
      let(:wrapper_close) { "END" }

      let(:content) do
        <<~FILE
          # typed: strong

          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 9 }
      let(:annotation) do
        <<~ANNOTATION
          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with annotations using wrapper_open and wrapper_close with a line break between the human comment" do
      let(:wrapper_open) { "START" }
      let(:wrapper_close) { "END" }

      let(:content) do
        <<~FILE
          # typed: strong

          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END

          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 9 }
      let(:annotation) do
        <<~ANNOTATION
          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with annotations using wrapper_open and wrapper_close but not appearing in the annotation" do
      let(:wrapper_open) { "START" }
      let(:wrapper_close) { "END" }

      let(:content) do
        <<~FILE
          # typed: strong

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 7 }
      let(:annotation) do
        <<~ANNOTATION
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with annotations using wrapper_open and wrapper_close, with wrapper_close missing in the annotation" do
      let(:wrapper_open) { "START" }
      let(:wrapper_close) { "END" }

      let(:content) do
        <<~FILE
          # typed: strong

          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 8 }
      let(:annotation) do
        <<~ANNOTATION
          # START
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end

    context "with annotations using wrapper_open and wrapper_close, with wrapper_open missing in the annotation" do
      let(:wrapper_open) { "START" }
      let(:wrapper_close) { "END" }

      let(:content) do
        <<~FILE
          # typed: strong

          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
          # Some comment about the User class
          class User < ApplicationRecord
          end
        FILE
      end
      let(:annotation_start) { 2 }
      let(:annotation_end) { 8 }
      let(:annotation) do
        <<~ANNOTATION
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          # END
        ANNOTATION
      end

      include_examples "finds and extracts the annotation"
    end
  end
end
