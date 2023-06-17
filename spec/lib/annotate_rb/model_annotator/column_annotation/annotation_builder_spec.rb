# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(column, model, max_size, options).build }
    let(:max_size) { 16 }

    describe "bare format" do
      let(:options) { AnnotateRb::Options.new({}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          <<~COLUMN
            #  id              :integer          not null, primary key
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is not the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          <<~COLUMN
            #  id              :integer          not null
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment" do
        let(:max_size) { 20 }

        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          <<~COLUMN
            #  id([is commented])  :integer          not null
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end
    end

    describe "rdoc format" do
      let(:options) { AnnotateRb::Options.new({format_rdoc: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end

        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # *id*::          <tt>integer, not null, primary key</tt>
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is not the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # *id*::          <tt>integer, not null</tt>
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment" do
        let(:max_size) { 20 }

        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # *id([is commented])*<tt>integer, not null</tt>
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end
    end

    describe "yard format" do
      let(:options) { AnnotateRb::Options.new({format_yard: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end

        let(:expected_result) do
          # Unsure if this is even proper yard.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # @!attribute id
            #   @return [Integer]
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is not the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # @!attribute id
            #   @return [Integer]
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment" do
        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # @!attribute id([is commented])
            #   @return [Integer]
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end
    end

    describe "markdown format" do
      let(:options) { AnnotateRb::Options.new({format_markdown: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end

        let(:expected_result) do
          # Unsure if this is even proper markdown.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # **`id`**               | `integer`          | `not null, primary key`
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is not the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper markdown.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # **`id`**               | `integer`          | `not null`
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment" do
        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper markdown.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN
            # **`id([is commented])`**   | `integer`          | `not null`
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end
    end
  end
end
