# frozen_string_literal: true

RSpec.describe Annotaterb::ModelAnnotator::ModelWrapper do
  include AnnotateTestHelpers

  describe "#columns" do
    subject { described_class.new(*args).columns }
    let(:args) { [klass, options] }

    let(:klass) do
      mock_class(:users,
        :id,
        [
          id_column,
          name_column
        ])
    end
    let(:id_column) { mock_column("id", :integer) }
    let(:name_column) { mock_column("name", :string, limit: 50) }

    context "with options[:ignore_columns]" do
      let(:options) { Annotaterb::Options.new({ignore_columns: "(id|updated_at|created_at)"}) }

      it "should filter the columns set in option[:ignore_columns]" do
        is_expected.to contain_exactly(name_column)
      end
    end
  end

  describe "#max_schema_info_width" do
    subject { described_class.new(*args).max_schema_info_width }

    let(:args) { [klass, options] }
    let(:klass) do
      mock_class(:users,
        :id,
        [
          id_column,
          name_column
        ])
    end
    let(:id_column) { mock_column("id", :integer, comment: "") }
    let(:name_column) { mock_column("name", :string, comment: "[is commented]") }

    context "with options[:with_comment] and options[:with_column_comments] are true" do
      let(:options) do
        Annotaterb::Options.new({
          with_comment: true,
          with_column_comments: true,
          format_rdoc: format_rdoc_option
        })
      end
      let(:with_comments_lentgh) { 2 }
      let(:rdoc_length) { options[:format_rdoc] ? 5 : 1 }
      let(:expect_length) { name_column.name.length + name_column.comment.length + with_comments_lentgh + rdoc_length }

      context "with options[:format_rdoc]" do
        let!(:format_rdoc_option) { true }

        it "should return the max width including the length of the comments and the length of the rdoc" do
          is_expected.to eq(expect_length)
        end
      end

      context "with options[:format_rdoc] is false" do
        let!(:format_rdoc_option) { false }

        it "should return the max width including the length of the comments" do
          is_expected.to eq(expect_length)
        end
      end
    end

    context "with options[:with_column_comments] is false" do
      let(:options) do
        Annotaterb::Options.new({
          with_comment: true,
          with_column_comments: false,
          format_rdoc: format_rdoc_option
        })
      end
      let(:rdoc_length) { options[:format_rdoc] ? 5 : 1 }
      let(:expect_length) { name_column.name.length + rdoc_length }

      context "with options[:format_rdoc]" do
        let!(:format_rdoc_option) { true }

        it "should return the max width including the length of the rdoc" do
          is_expected.to eq(expect_length)
        end
      end

      context "with options[:format_rdoc] is false" do
        let!(:format_rdoc_option) { false }

        it "should return the max width" do
          is_expected.to eq(expect_length)
        end
      end
    end
  end
end
