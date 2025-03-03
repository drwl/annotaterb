# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::ColumnAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    let(:max_size) { 16 }

    describe "bare format" do
      subject { described_class.new(column, model, max_size, options).build.to_default }

      let(:options) { AnnotateRb::Options.new({with_comment: true, with_column_comments: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {},
            built_attributes: {"id" => ["not null", "primary key"]}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => ["not null"]}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  id              :integer          not null
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is string column and an array (postgres)" do
        let(:column) { mock_column("notifications", :string, default: "{}", array: true, null: true) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {
              "notifications" => []
            },
            built_attributes: {'notifications' => ['default([])', 'is an Array']}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  notifications   :string           default([]), is an Array
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is string column and an array with a default (postgres)" do
        let(:column) { mock_column("notifications", :string, default: "{}", array: true, null: true) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {
              "notifications" => ["something"]
            },
            built_attributes: {"notifications" => ['default(["something"])', 'is an Array']}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  notifications   :string           default(["something"]), is an Array
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column is a string column with a default" do
        let(:column) { mock_column("notifications", :string, default: "alert", null: true) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {
              "notifications" => "alert"
            },
            built_attributes: {"notifications" => ['default("alert")']}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  notifications   :string           default("alert")
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
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end

        let(:expected_result) do
          <<~COLUMN.strip
            #  id([is commented])  :integer          not null
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end

        context "when position of column comment is set to `rightmost_column`" do
          let(:options) do
            AnnotateRb::Options.new({
              with_comment: true,
              with_column_comments: true,
              position_of_column_comment: :rightmost_column
            })
          end

          let(:expected_result) do
            <<~COLUMN.strip
              #  id                  :integer          not null     [is commented]
            COLUMN
          end

          it "returns the column annotation" do
            is_expected.to eq(expected_result)
          end
        end
      end

      context "when the column has a multi-byte comment" do
        let(:max_size) { 20 }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {},
            built_attributes: {
              "id" => ['not null'],
              "cyrillic" => ['not null'],
              "japanese" => ['not null'],
              "arabic" => ['not null'],
            }
          )
        end

        context "with column comment 'ＩＤ'" do
          let(:column) { mock_column("id", :integer, limit: 8, comment: "ＩＤ") }
          let(:expected_result) { "#  id(ＩＤ)            :integer          not null" }

          it "returns the column annotation" do
            is_expected.to eq(expected_result)
          end
        end

        context "with column comment in Cyrillic" do
          let(:column) { mock_column("cyrillic", :text, limit: 30, comment: "Кириллица") }
          let(:expected_result) { "#  cyrillic(Кириллица) :text(30)         not null" }

          it "returns the column annotation" do
            is_expected.to eq(expected_result)
          end
        end

        context "with column comment in Japanese" do
          let(:column) { mock_column("japanese", :text, limit: 60, comment: "熊本大学　イタリア　宝島") }
          let(:expected_result) { "#  japanese(熊本大学　イタリア　宝:text(60)         not null" }

          it "returns the column annotation" do
            is_expected.to eq(expected_result)
          end
        end

        context "with column comment in Arabic" do
          let(:column) { mock_column("arabic", :text, limit: 20, comment: "لغة") }
          let(:expected_result) { "#  arabic(لغة)         :text(20)         not null" }

          it "returns the column annotation" do
            is_expected.to eq(expected_result)
          end
        end
      end

      context "when the column has a multi-line comment" do
        let(:max_size) { 45 }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {},
            built_attributes: {"notes" => ['not null']}
          )
        end

        let(:column) { mock_column("notes", :text, limit: 55, comment: "Notes.\nMay include things like notes.") }
        let(:expected_result) { "#  notes(Notes.\\nMay include things like notes.):text(55)         not null" }

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment and without comment options" do
        let(:options) { AnnotateRb::Options.new({with_comment: false, with_column_comments: false}) }
        let(:max_size) { 20 }

        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  id                  :integer          not null
          COLUMN
        end

        it "returns the column annotation without the comment" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment and with `with_comment: true`" do
        let(:options) { AnnotateRb::Options.new({with_comment: true, with_column_comments: false}) }
        let(:max_size) { 20 }

        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  id                  :integer          not null
          COLUMN
        end

        it "returns the column annotation without the comment" do
          is_expected.to eq(expected_result)
        end
      end

      context "when the column has a comment and with `with_column_comments: true`" do
        let(:options) { AnnotateRb::Options.new({with_comment: false, with_column_comments: true}) }
        let(:max_size) { 20 }

        let(:column) { mock_column("id", :integer, comment: "[is commented]") }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "something_else",
            retrieve_indexes_from_table: [],
            with_comments?: true,
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end
        let(:expected_result) do
          <<~COLUMN.strip
            #  id                  :integer          not null
          COLUMN
        end

        it "returns the column annotation without the comment" do
          is_expected.to eq(expected_result)
        end
      end
    end

    describe "rdoc format" do
      subject { described_class.new(column, model, max_size, options).build.to_rdoc }

      let(:options) { AnnotateRb::Options.new({format_rdoc: true, with_comment: true, with_column_comments: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {},
            built_attributes: {"id" => ['not null', 'primary key']}
          )
        end

        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => ["not null"]}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
            # *id([is commented])*<tt>integer, not null</tt>
          COLUMN
        end

        it "returns the column annotation" do
          is_expected.to eq(expected_result)
        end
      end
    end

    describe "yard format" do
      subject { described_class.new(column, model, max_size, options).build.to_yard }

      let(:options) { AnnotateRb::Options.new({format_yard: true, with_comment: true, with_column_comments: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:column_defaults) { {} }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {},
            built_attributes: {"id" => []}
          )
        end

        let(:expected_result) do
          # Unsure if this is even proper yard.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => []}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => []}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper rdoc.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
      subject { described_class.new(column, model, max_size, options).build.to_markdown }

      let(:options) { AnnotateRb::Options.new({format_markdown: true, with_comment: true, with_column_comments: true}) }

      context "when the column is the primary key" do
        let(:column) { mock_column("id", :integer) }
        let(:model) do
          instance_double(
            AnnotateRb::ModelAnnotator::ModelWrapper,
            primary_key: "id",
            retrieve_indexes_from_table: [],
            with_comments?: false,
            column_defaults: {},
            built_attributes: {"id" => ['not null', 'primary key']}
          )
        end

        let(:expected_result) do
          # Unsure if this is even proper markdown.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper markdown.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
            column_defaults: {},
            built_attributes: {"id" => ['not null']}
          )
        end
        let(:expected_result) do
          # Unsure if this is even proper markdown.
          # TODO: Check and fix if this is incorrect.
          <<~COLUMN.strip
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
