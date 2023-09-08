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
end
