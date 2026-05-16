# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::MagicComment do
  describe ".match?" do
    subject { described_class.match?(line) }

    context "with simple style magic comments" do
      [
        "# encoding: UTF-8",
        "# coding: UTF-8",
        "# frozen_string_literal: true",
        "# frozen-string-literal: false",
        "# warn_indent: true",
        "# shareable_constant_value: literal",
        "# shareable-constant-value: experimental_everything",
        "# typed: true",
        "# typed: strict",
        "# typed: ignore",
        "# rbs_inline: enabled",
        "# rbs_inline: disabled"
      ].each do |line|
        context "when line is #{line.inspect}" do
          let(:line) { line }
          it { is_expected.to be true }
        end
      end
    end

    context "with surrounding whitespace and trailing content" do
      let(:line) { "  #   frozen_string_literal:    true   " }
      it { is_expected.to be true }
    end

    context "with Emacs style magic comment" do
      let(:line) { "# -*- coding: utf-8; frozen_string_literal: true -*-" }
      it { is_expected.to be true }
    end

    context "with Vim style modeline" do
      let(:line) { "# vim: fileencoding=utf-8 ft=ruby" }
      it { is_expected.to be true }
    end

    context "with a normal class documentation comment" do
      let(:line) { "# Represents a registered user account" }
      it { is_expected.to be false }
    end

    context "with a comment that has a colon but no recognized key" do
      let(:line) { "# Note: this comment is not a magic comment" }
      it { is_expected.to be false }
    end

    context "with a YARD style tag comment" do
      let(:line) { "# @return [String]" }
      it { is_expected.to be false }
    end

    context "with a non-comment line" do
      let(:line) { "class User < ApplicationRecord" }
      it { is_expected.to be false }
    end

    context "with a blank line" do
      let(:line) { "" }
      it { is_expected.to be false }
    end

    context "with an empty comment marker" do
      let(:line) { "#" }
      it { is_expected.to be false }
    end
  end
end
