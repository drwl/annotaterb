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
      let(:expected_starts) { [["User", 0]] }
      let(:expected_ends) { [["User", 1]] }

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
          ["# typed: strong", 0],
          ["# == Schema Information", 2],
          ["#", 3],
          ["# Table name: users", 4],
          ["#", 5],
          ["#  id                     :bigint           not null, primary key", 6],
          ["#", 7]
        ]
      end
      let(:expected_starts) { [["User", 8]] }
      let(:expected_ends) { [["User", 9]] }

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
      let(:expected_starts) { [["Admin", 0], ["User", 1]] }
      let(:expected_ends) { [["User", 2], ["Admin", 3]] }

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
          ["# typed: strong", 0],
          ["# == Schema Information", 2],
          ["#", 3],
          ["# Table name: users", 4],
          ["#", 5],
          ["#  id                     :bigint           not null, primary key", 6],
          ["#", 7]
        ]
      end
      let(:expected_starts) { [["Admin", 8], ["User", 9]] }
      let(:expected_ends) { [["User", 10], ["Admin", 11]] }

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
          ["=begin", 0],
          ["This is", 1],
          ["commented out", 2],
          ["=end", 3],
          ["=begin some_tag", 8],
          ["this works, too", 9],
          ["=end", 10]
        ]
      end
      let(:expected_starts) { [["Foo", 5]] }
      let(:expected_ends) { [["Foo", 6]] }

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
      let(:expected_starts) { [["User", 0]] }
      let(:expected_ends) { [["Foo", 1]] }

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
      let(:expected_starts) { [["Fabricator", 0], ["reminder_at", 2]] }
      let(:expected_ends) { [["reminder_at", 2], ["end", 3], ["Fabricator", 3]] }

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
      let(:expected_starts) { [["FactoryBot", 0], ["factory", 1], ["admin", 2], ["FactoryBot", 4]] }
      let(:expected_ends) { [["admin", 2], ["end", 3], ["factory", 3], ["end", 4]] }

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
        [["factory", 0], ["first_name", 1], ["last_name", 2], ["date_of_birth", 3]]
      }
      let(:expected_ends) { [["first_name", 1], ["last_name", 2], ["date_of_birth", 3], ["end", 4], ["factory", 4]] }

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
      let(:expected_comments) { [["# typed: strong", 0]] }
      let(:expected_starts) { [["factory", 1], ["first_name", 2], ["last_name", 3], ["date_of_birth", 4]] }
      let(:expected_ends) { [["first_name", 2], ["last_name", 3], ["date_of_birth", 4], ["end", 5], ["factory", 5]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when using an RSpec file" do
      let(:input) do
        <<~FILE
          RSpec.describe "Collapsed::TestModel" do
            # Deliberately left empty
          end
        FILE
      end
      let(:expected_comments) { [["# Deliberately left empty", 1]] }
      let(:expected_starts) { [["RSpec", 0]] }
      let(:expected_ends) { [["end", 2], ["RSpec", 2]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "when using an RSpec file with monkeypatching" do
      # Should be removed by RSpec 4+
      # https://github.com/rspec/rspec-core/issues/2301
      let(:input) do
        <<~FILE
          describe "Collapsed::TestModel" do
            # Deliberately left empty
          end
        FILE
      end
      let(:expected_comments) { [["# Deliberately left empty", 1]] }
      let(:expected_starts) { [["describe", 0]] }
      let(:expected_ends) { [["end", 2], ["describe", 2]] }

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
          ["# typed: strong", 0],
          ["=begin", 2],
          ["first line", 3],
          ["second line", 4],
          ["=end", 5],
          ["# == Schema Information", 7],
          ["#", 8],
          ["# Table name: users", 9],
          ["#", 10],
          ["#  id                     :bigint           not null, primary key", 11],
          ["#", 12]
        ]
      end
      let(:expected_starts) { [["User", 13]] }
      let(:expected_ends) { [["User", 14]] }

      it "parses correctly" do
        check_it_parses_correctly
      end
    end

    context "with a fixture yml file" do
      
    end
  end
end
