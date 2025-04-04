# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnAnnotation::TypeBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(column, options, column_defaults).build }

    let(:column) {}
    let(:column_defaults) { {} }
    let(:options) { AnnotateRb::Options.new({}) }

    before do
      stub_const("#{described_class}::NO_LIMIT_COL_TYPES", %w[integer bigint boolean].freeze)
    end

    context "with an integer column" do
      let(:column) { mock_column("id", :integer) }
      let(:expected_result) { "integer" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a string column with a limit" do
      let(:column) { mock_column("name", :string, limit: 50) }
      let(:expected_result) { "string(50)" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a text column with a limit" do
      let(:column) { mock_column("notes", :text, limit: 55) }
      let(:expected_result) { "text(55)" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a enum column" do
      let(:column) { mock_column("name", :enum, limit: [:enum1, :enum2]) }
      let(:expected_result) { "enum" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a decimal column" do
      let(:column) { mock_column("decimal", :decimal, unsigned?: true, precision: 10, scale: 2) }
      let(:expected_result) { "decimal(10, 2)" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a float column" do
      let(:column) { mock_column("float", :float, unsigned?: true) }
      let(:expected_result) { "float" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a bigint column" do
      let(:column) { mock_column("bigint", :integer, unsigned?: true, bigint?: true) }
      let(:expected_result) { "bigint" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a string column with a limit" do
      let(:column) { mock_column("name", :enum, limit: [:enum1, :enum2]) }
      let(:expected_result) { "enum" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a boolean" do
      let(:column) { mock_column("flag", :boolean, default: false) }
      let(:expected_result) { "boolean" }

      it { is_expected.to eq(expected_result) }
    end

    context "with a virtual column without option enabled" do
      context "when show_virtual_columns if false" do
        let(:column) { mock_column("name", :string, virtual?: true) }
        let(:options) do
          AnnotateRb::Options.new({show_virtual_columns: false})
        end
        let(:expected_result) { "string" }

        it { is_expected.to eq(expected_result) }
      end

      context "when show_virtual_columns if true" do
        let(:column) { mock_column("name", :string, virtual?: true) }
        let(:options) do
          AnnotateRb::Options.new({show_virtual_columns: true})
        end
        let(:expected_result) { "virtual(string)" }

        it { is_expected.to eq(expected_result) }
      end
    end

    context 'when "format_yard" is specified in options' do
      context "with a string column with a limit" do
        let(:column) { mock_column("name", :string, limit: 50) }
        let(:options) do
          AnnotateRb::Options.new({format_yard: true})
        end
        let(:expected_result) { "string" }

        it { is_expected.to eq(expected_result) }
      end
    end

    context 'when "hide_limit_column_types" is specified in options' do
      context 'when "hide_limit_column_types" is blank string' do
        let(:column) { mock_column("name", :string, limit: 50) }
        let(:options) do
          AnnotateRb::Options.new({hide_limit_column_types: ""})
        end
        let(:expected_result) { "string(50)" }

        it { is_expected.to eq(expected_result) }
      end

      context 'when "hide_limit_column_types" is "integer,boolean" with a string column' do
        let(:column) { mock_column("name", :string, limit: 50) }
        let(:options) do
          AnnotateRb::Options.new({hide_limit_column_types: "integer,boolean"})
        end
        let(:expected_result) { "string(50)" }

        it { is_expected.to eq(expected_result) } # Doesn't change string limit since not specified
      end

      context 'when "hide_limit_column_types" is "integer,boolean" with an integer column' do
        let(:column) { mock_column("id", :integer, limit: 8) }
        let(:options) do
          AnnotateRb::Options.new({hide_limit_column_types: "integer,boolean"})
        end
        let(:expected_result) { "integer" }

        it { is_expected.to eq(expected_result) }
      end

      context 'when "hide_limit_column_types" is "integer,boolean" with a boolean column' do
        let(:column) { mock_column("active", :boolean, limit: 1) }
        let(:options) do
          AnnotateRb::Options.new({hide_limit_column_types: "integer,boolean"})
        end
        let(:expected_result) { "boolean" }

        it { is_expected.to eq(expected_result) }
      end

      context 'when "hide_limit_column_types" is "integer,boolean,string,text"' do
        let(:column) { mock_column("name", :string, limit: 50) }
        let(:options) do
          AnnotateRb::Options.new({hide_limit_column_types: "integer,boolean,string,text"})
        end
        let(:expected_result) { "string" }

        it { is_expected.to eq(expected_result) }
      end
    end
  end
end
