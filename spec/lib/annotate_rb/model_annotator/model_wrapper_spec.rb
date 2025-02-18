# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ModelWrapper do
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
      let(:options) { AnnotateRb::Options.new({ignore_columns: "(id|updated_at|created_at)"}) }

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
        AnnotateRb::Options.new({
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
        AnnotateRb::Options.new({
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

  describe "#enum_columns" do
    let(:options) { {} }
    let(:connection) { double("connection") }
    let(:klass) { double("klass", connection: connection) }
    let(:wrapper) { described_class.new(klass, options) }
    let(:enum_column) do
      double("column",
             name: "status",
             type: :enum,
             sql_type_metadata: double("metadata", sql_type: "enum('active', 'inactive')"))
    end

    before do
      allow(wrapper).to receive(:raw_columns).and_return([enum_column])
      allow(connection).to receive(:respond_to?).with(:enum_types).and_return(true)
      allow(connection).to receive(:enum_types).and_return([
        ["enum('active', 'inactive')", "'active', 'inactive'"]
      ])
    end

    it "returns enum column information" do
      expect(wrapper.enum_columns).to eq([{
        name: "status",
        enum_type: "active', 'inactive",
        values: ["active", "inactive"],
        max_size: wrapper.max_schema_info_width,
        type: :enum
      }])
    end

    context "when connection doesn't support enum_types" do
      before do
        allow(connection).to receive(:respond_to?).with(:enum_types).and_return(false)
      end

      it "returns empty array" do
        expect(wrapper.enum_columns).to eq([])
      end
    end
  end
end
