# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::CustomParser do
  describe ".parse" do
    subject { described_class.parse(input) }

    def check_it_parses_correctly
      expect(subject.comments).to eq(expected_comments)
      expect(subject.starts).to eq(expected_starts)
      expect(subject.ends).to eq(expected_ends)
    end

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
      let(:expected_comments) do
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
      let(:expected_starts) { [["User", 9]] }
      let(:expected_ends) { [["User", 10]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when class is namespaced in a module" do
      let(:input) do
        <<~FILE
          # typed: strong
          
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          module Admin
            class User < ApplicationRecord
            end  
          end
        FILE
      end
      let(:expected_comments) do
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
      let(:expected_starts) { [["Admin", 9], ["User", 10]] }
      let(:expected_ends) { [["User", 11], ["Admin", 12]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
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
      let(:expected_comments) do
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
      let(:expected_starts) { [["Foo", 6]] }
      let(:expected_ends) { [["Foo", 7]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when file body has no comments" do
      let(:input) do
        <<~FILE
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_comments) do
        []
      end
      let(:expected_starts) { [["User", 1]] }
      let(:expected_ends) { [["User", 2]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when class is defined on a namespace" do
      let(:input) do
        <<~FILE
          class Foo::User < ApplicationRecord
          end
        FILE
      end
      let(:expected_comments) do
        []
      end
      let(:expected_starts) { [["User", 1]] }
      let(:expected_ends) { [["Foo", 2]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
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
      let(:expected_comments) do
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
      let(:expected_starts) { [["User", 14]] }
      let(:expected_ends) { [["User", 15]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end
  end
end
