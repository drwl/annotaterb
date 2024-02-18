# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::FileParser::CustomParser do
  describe ".parse" do
    subject { described_class.parse(input) }

    def check_it_parses_correctly
      expect(subject.comments).to eq(expected_comments)
      expect(subject.starts).to eq(expected_starts)
      expect(subject.ends).to eq(expected_ends)
    end

    context "with a simple ActiveRecord model class" do
      let(:input) do
        <<~FILE
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_comments) { [] }
      let(:expected_starts) { [["User", 1]] }
      let(:expected_ends) { [["User", 2]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "with a simple ActiveRecord model class with comments" do
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
          module Admin
            class User < ApplicationRecord
            end
          end
        FILE
      end
      let(:expected_comments) { [] }
      let(:expected_starts) { [["Admin", 1], ["User", 2]] }
      let(:expected_ends) { [["User", 3], ["Admin", 4]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when class is namespaced in a module with comments" do
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

    context "when class is defined on a namespace" do
      let(:input) do
        <<~FILE
          class Foo::User < ApplicationRecord
          end
        FILE
      end
      let(:expected_comments) { [] }
      let(:expected_starts) { [["User", 1]] }
      let(:expected_ends) { [["Foo", 2]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when using Fabrication fabricators" do
      let(:input) do
        <<~FILE
          Fabricator(:bookmark) do
            user
            reminder_at { 1.day.from_now.iso8601 }
          end
        FILE
      end
      let(:expected_comments) { [] }
      let(:expected_starts) { [["Fabricator", 1], ["reminder_at", 3]] }
      let(:expected_ends) { [["reminder_at", 3], ["end", 4], ["Fabricator", 4]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when using FactoryBot factories" do
      let(:input) do
        <<~FILE
          FactoryBot.define do
            factory :user do
              admin { false }
            end
          end
        FILE
      end
      let(:expected_comments) { [] }
      let(:expected_starts) { [["FactoryBot", 1], ["factory", 2], ["admin", 3], ["factory", 4], ["FactoryBot", 5]] }
      let(:expected_ends) { [["admin", 3], ["end", 4], ["end", 5]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when using FactoryBot factories alias" do
      let(:input) do
        <<~FILE
          factory :user, aliases: [:author, :commenter] do
            first_name { "John" }
            last_name { "Doe" }
            date_of_birth { 18.years.ago }
          end
        FILE
      end
      let(:expected_comments) { [] }
      let(:expected_starts) {
        [["factory", 1], ["first_name", 2], ["last_name", 3], ["date_of_birth", 4], ["factory", 5]]
      }
      let(:expected_ends) { [["first_name", 2], ["last_name", 3], ["date_of_birth", 4], ["end", 5]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when using FactoryBot factories alias with comments" do
      let(:input) do
        <<~FILE
          # typed: strong
          factory :user, aliases: [:author, :commenter] do
            first_name { "John" }
            last_name { "Doe" }
            date_of_birth { 18.years.ago }
          end
        FILE
      end
      let(:expected_comments) { [["# typed: strong", 1]] }
      let(:expected_starts) { [["factory", 2], ["first_name", 3], ["last_name", 4], ["date_of_birth", 5], ["factory", 6]] }
      let(:expected_ends) { [["first_name", 3], ["last_name", 4], ["date_of_birth", 5], ["end", 6]] }

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
