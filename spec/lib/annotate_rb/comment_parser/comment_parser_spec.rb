# frozen_string_literal: true

RSpec.describe AnnotateRb::CommentParser::CommentParser do
  describe ".parse" do
    subject { described_class.parse(input) }

    context "when file body has single line comments" do
      let(:input) do
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
      let(:output) do
        [
          ["# typed: strong", 1],
          ["# == Schema Information", 3],
          ["#", 4],
          ["# Table name: users", 5],
          ["#", 6],
          ["#  id                     :bigint           not null, primary key", 7],
          ["#", 8]
        ]
      end

      it { is_expected.to eq(output) }
    end

    context "when file has block comments" do
      let(:input) do
        <<~FILE
          =begin
          This is
          commented out
          =end

          class Foo
          end

          =begin some_tag
          this works, too
          =end
        FILE
      end
      let(:output) do
        [
          ["=begin", 1],
          ["This is", 2],
          ["commented out", 3],
          ["=end", 4],
          ["=begin some_tag", 9],
          ["this works, too", 10],
          ["=end", 11]
        ]
      end

      it { is_expected.to eq(output) }
    end

    context "when file body has no comments" do
      let(:input) do
        <<~FILE
          class User < ApplicationRecord
          end
        FILE
      end
      let(:output) do
        []
      end

      it { is_expected.to eq(output) }
    end

    context "when file body has single line and block comments" do
      let(:input) do
        <<~FILE
          # typed: strong

          =begin
          first line
          second line
          =end

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
      let(:output) do
        [
          ["# typed: strong", 1],
          ["=begin", 3],
          ["first line", 4],
          ["second line", 5],
          ["=end", 6],
          ["# == Schema Information", 8],
          ["#", 9],
          ["# Table name: users", 10],
          ["#", 11],
          ["#  id                     :bigint           not null, primary key", 12],
          ["#", 13]
        ]
      end

      it { is_expected.to eq(output) }
    end
  end
end
