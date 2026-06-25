# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::ParsedFile do
  describe "#parse" do
    subject { described_class.new(file_content, new_annotations, parser_klass, options).parse }

    let(:parser_klass) { AnnotateRb::ModelAnnotator::FileParser::CustomParser }
    let(:options) { AnnotateRb::Options.new({}) }
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

    # Regression: when the annotation is at the very top of the file (annotation_start == 0),
    # `@file_lines[annotation_start - 1]` used to wrap around to `@file_lines[-1]` (the last
    # line). If the file ended with a blank line, this was mistaken for leading whitespace,
    # decremented annotation_start to -1, and produced an empty `annotations_with_whitespace`.
    # An empty removal string is a no-op, so old annotations were never removed and duplicated.
    context "when the annotation is at the top of the file and the file ends with a blank line" do
      let(:file_content) do
        "# == Schema Information\n" \
          "#\n" \
          "# Table name: users\n" \
          "#\n" \
          "#  id                     :bigint           not null, primary key\n" \
          "#\n" \
          "class User < ApplicationRecord\n" \
          "end\n" \
          "\n"
      end

      it "does not treat the trailing blank line as leading whitespace" do
        expect(subject.has_leading_whitespace?).to eq(false)
      end

      it "captures the annotation in annotations_with_whitespace" do
        expect(subject.annotations_with_whitespace).not_to be_empty
        expect(subject.annotations_with_whitespace).to include("# == Schema Information")
      end
    end
  end
end
