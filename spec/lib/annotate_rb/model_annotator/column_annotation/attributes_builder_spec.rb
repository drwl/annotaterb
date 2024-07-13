# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnAnnotation::AttributesBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(column, options, is_primary_key, column_indices, column_defaults).build }

    let(:column) {}
    let(:column_defaults) { {} }
    let(:options) { AnnotateRb::Options.new({}) }
    let(:is_primary_key) {}
    let(:column_indices) {}

    context "when the primary key is not specified" do
      let(:is_primary_key) { false }

      context "when the column is normal" do
        let(:column) { mock_column("id", :integer) }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "when an enum column exists" do
        let(:column) { mock_column("name", :enum, limit: [:enum1, :enum2]) }
        let(:expected_result) { ["not null", "(enum1, enum2)"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "when an unsigned columns exist" do
        let(:column) { mock_column("integer", :integer, unsigned?: true) }
        let(:expected_result) { ["unsigned", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "when column is an integer with a default value" do
        let(:column) { mock_column("size", :integer, default: 20) }
        let(:column_defaults) { {"size" => 20} }
        let(:expected_result) { ["default(20)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "when column is a boolean with a default value" do
        let(:column) { mock_column("flag", :boolean, default: false) }
        let(:column_defaults) { {"flag" => false} }
        let(:expected_result) { ["default(FALSE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end
    end

    context "when the primary key is specified" do
      let(:is_primary_key) { true }

      context "with an id integer primary key column" do
        let(:column) { mock_column("id", :integer, limit: 8) }
        let(:expected_result) { ["not null", "primary key"] }

        it { is_expected.to match_array(expected_result) }
      end
    end

    context "when a column has an index and simple_indexes option is true" do
      let(:is_primary_key) { true }
      let(:options) { AnnotateRb::Options.new({simple_indexes: true}) }

      context "with an id integer primary key column" do
        let(:column) { mock_column("id", :integer) }
        let(:expected_result) { ["not null", "primary key", "indexed"] }

        let(:column_indices) do
          [
            mock_index("index_rails_02e851e3b7", columns: ["id"])
          ]
        end

        it { is_expected.to match_array(expected_result) }
      end

      context "with a column including an index" do
        let(:column) { mock_column("firstname", :string) }
        let(:expected_result) { ["indexed => [surname]", "not null", "primary key"] }

        let(:column_indices) do
          [
            mock_index("index_rails_02e851e3b8",
              columns: %w[firstname surname],
              where: "value IS NOT NULL")
          ]
        end

        it { is_expected.to match_array(expected_result) }
      end

      context "with a column includes an ordered index key 1" do
        let(:column) { mock_column("firstname", :string) }
        let(:expected_result) { ["indexed => [surname, value]", "not null", "primary key"] }

        let(:column_indices) do
          [
            mock_index("index_rails_02e851e3b8",
              columns: %w[firstname surname value],
              orders: {"surname" => :asc, "value" => :desc})
          ]
        end

        it { is_expected.to match_array(expected_result) }
      end

      context "with a column includes an ordered index key 2" do
        let(:column) { mock_column("surname", :string) }
        let(:expected_result) { ["indexed => [firstname, value]", "not null", "primary key"] }

        let(:column_indices) do
          [
            mock_index("index_rails_02e851e3b8",
              columns: %w[firstname surname value],
              orders: {"surname" => :asc, "value" => :desc})
          ]
        end

        it { is_expected.to match_array(expected_result) }
      end

      context "with a column includes an ordered index key 3" do
        let(:column) { mock_column("value", :string) }
        let(:expected_result) { ["indexed => [firstname, surname]", "not null", "primary key"] }

        let(:column_indices) do
          [
            mock_index("index_rails_02e851e3b8",
              columns: %w[firstname surname value],
              orders: {"surname" => :asc, "value" => :desc})
          ]
        end

        it { is_expected.to match_array(expected_result) }
      end

      context "with a column including an index in string form" do
        let(:column) { mock_column("name", :string) }
        let(:expected_result) { ["not null", "primary key"] }

        let(:column_indices) do
          [
            mock_index("index_rails_02e851e3b8", columns: "LOWER(name)")
          ]
        end

        it { is_expected.to match_array(expected_result) }
      end
    end

    context "when the hide_default_column_types option is 'skip' with a json column" do
      let(:options) { AnnotateRb::Options.new({hide_default_column_types: "skip"}) }
      let(:column_defaults) { {"profile" => {}} }

      let(:is_primary_key) { false }
      let(:column) { mock_column("profile", :json, default: {}) }
      let(:expected_result) { ["default({})", "not null"] }

      it { is_expected.to match_array(expected_result) }
    end

    context "when the hide_default_column_types option is 'skip' with a jsonb column" do
      let(:options) { AnnotateRb::Options.new({hide_default_column_types: "skip"}) }
      let(:column_defaults) { {"settings" => {}} }

      let(:is_primary_key) { false }
      let(:column) { mock_column("settings", :jsonb, default: {}) }
      let(:expected_result) { ["default({})", "not null"] }

      it { is_expected.to match_array(expected_result) }
    end

    context "when the hide_default_column_types option is 'skip' with a hstore column" do
      let(:options) { AnnotateRb::Options.new({hide_default_column_types: "skip"}) }
      let(:column_defaults) { {"parameters" => {}} }

      let(:is_primary_key) { false }
      let(:column) { mock_column("parameters", :hstore, default: {}) }
      let(:expected_result) { ["default({})", "not null"] }

      it { is_expected.to match_array(expected_result) }
    end

    context "when the hide_default_column_types option is 'json' with a json column" do
      let(:options) { AnnotateRb::Options.new({hide_default_column_types: "json"}) }
      let(:column_defaults) { {"profile" => {}} }

      let(:is_primary_key) { false }
      let(:column) { mock_column("profile", :json, default: {}) }
      let(:expected_result) { ["not null"] }

      it { is_expected.to match_array(expected_result) }
    end

    context "when the hide_default_column_types option is 'json' with a non-json column" do
      let(:options) { AnnotateRb::Options.new({hide_default_column_types: "json"}) }
      let(:column_defaults) { {"settings" => {}} }

      let(:is_primary_key) { false }
      let(:column) { mock_column("settings", :jsonb, default: {}) }
      let(:expected_result) { ["default({})", "not null"] }

      it { is_expected.to match_array(expected_result) }
    end

    context "column defaults in sqlite" do
      # Mocked representations when using the sqlite adapter
      context "with an integer default value of 0" do
        let(:column) { mock_column("amount", :integer, default: "0") }
        let(:column_defaults) { {"amount" => 0} }
        let(:expected_result) { ["default(0)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with an integer default value of 1" do
        let(:column) { mock_column("amount", :integer, default: "1") }
        let(:column_defaults) { {"amount" => 1} }
        let(:expected_result) { ["default(1)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with an integer field without a default" do
        let(:column) { mock_column("amount", :integer, default: nil) }
        let(:column_defaults) { {"amount" => nil} }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with default of false" do
        let(:column) { mock_column("flag", :boolean, default: "0") }
        let(:column_defaults) { {"flag" => false} }
        let(:expected_result) { ["default(FALSE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with default of true" do
        let(:column) { mock_column("flag", :boolean, default: "1") }
        let(:column_defaults) { {"flag" => true} }
        let(:expected_result) { ["default(TRUE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with a boolean field without a default" do
        let(:column) { mock_column("flag", :boolean, default: nil) }
        let(:column_defaults) { {"flag" => nil} }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end
    end

    context "column defaults in mysql" do
      # Mocked representations when using the mysql adapter
      context "with an integer default value of 0" do
        let(:column) { mock_column("amount", :integer, default: "0") }
        let(:column_defaults) { {"amount" => 0} }
        let(:expected_result) { ["default(0)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with an integer default value of 1" do
        let(:column) { mock_column("amount", :integer, default: "1") }
        let(:column_defaults) { {"amount" => 1} }
        let(:expected_result) { ["default(1)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with an integer field without a default" do
        let(:column) { mock_column("amount", :integer, default: nil) }
        let(:column_defaults) { {"amount" => 0} }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with default of false" do
        let(:column) { mock_column("flag", :boolean, default: "0") }
        let(:column_defaults) { {"flag" => false} }
        let(:expected_result) { ["default(FALSE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with default of true" do
        let(:column) { mock_column("flag", :boolean, default: "1") }
        let(:column_defaults) { {"flag" => true} }
        let(:expected_result) { ["default(TRUE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with a boolean field without a default" do
        let(:column) { mock_column("flag", :boolean, default: nil) }
        let(:column_defaults) { {"flag" => nil} }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end
    end

    context "column defaults in postgres" do
      # Mocked representations when using the postgresql adapter
      context "with an integer default value of 0" do
        let(:column) { mock_column("amount", :integer, default: "0") }
        let(:column_defaults) { {"amount" => 0} }
        let(:expected_result) { ["default(0)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with an integer default value of 1" do
        let(:column) { mock_column("amount", :integer, default: "1") }
        let(:column_defaults) { {"amount" => 1} }
        let(:expected_result) { ["default(1)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with an integer field without a default" do
        let(:column) { mock_column("amount", :integer, default: nil) }
        let(:column_defaults) { {"amount" => nil} }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with default of false" do
        let(:column) { mock_column("flag", :boolean, default: "0") }
        let(:column_defaults) { {"flag" => false} }
        let(:expected_result) { ["default(FALSE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with default of true" do
        let(:column) { mock_column("flag", :boolean, default: "1") }
        let(:column_defaults) { {"flag" => true} }
        let(:expected_result) { ["default(TRUE)", "not null"] }

        it { is_expected.to match_array(expected_result) }
      end

      context "with a boolean field without a default" do
        let(:column) { mock_column("flag", :boolean, default: nil) }
        let(:column_defaults) { {"flag" => nil} }
        let(:expected_result) { ["not null"] }

        it { is_expected.to match_array(expected_result) }
      end
    end
  end
end
