# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::IndexAnnotation::AnnotationBuilder do
  include AnnotateTestHelpers

  describe "#build" do
    subject { described_class.new(model, options).build }
    let(:default_format) { subject.to_default }
    let(:markdown_format) { subject.to_markdown }
    let(:yard_format) { subject.to_yard }
    let(:rdoc_format) { subject.to_rdoc }

    let(:model) do
      klass = begin
        primary_key = nil
        columns = []
        foreign_keys = []

        mock_class(
          :users,
          primary_key,
          columns,
          indexes,
          foreign_keys
        )
      end

      ::AnnotateRb::ModelAnnotator::ModelWrapper.new(klass, options)
    end
    let(:options) { ::AnnotateRb::Options.new({show_indexes: true}) }
    let(:indexes) { [mock_index("index_rails_02e851e3b7", columns: ["id"])] }

    context "when show_indexes option is false" do
      let(:options) { ::AnnotateRb::Options.new({show_indexes: false}) }

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "when there are no indexes" do
      let(:indexes) { [] }

      it { is_expected.to be_a(AnnotateRb::ModelAnnotator::Components::NilComponent) }
    end

    context "index includes an ordered index key" do
      let(:indexes) do
        [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8",
            columns: %w[firstname surname value],
            orders: {"surname" => :asc, "value" => :desc})
        ]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (firstname,surname ASC,value DESC)
        EOS
      end

      it "matches the expected result" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "index includes a where clause" do
      let(:indexes) do
        [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8",
            columns: %w[firstname surname],
            where: "value IS NOT NULL")
        ]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (firstname,surname) WHERE value IS NOT NULL
        EOS
      end

      it "matches the expected result" do
        expect(default_format).to eq(expected_result)
      end
    end

    context 'index includes a "using" clause other than "btree"' do
      let(:indexes) do
        [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8",
            columns: %w[firstname surname],
            using: "hash")
        ]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (firstname,surname) USING hash
        EOS
      end

      it "matches the expected result" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "index includes has a string form" do
      let(:indexes) do
        [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8", columns: "LOWER(name)")
        ]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (LOWER(name))
        EOS
      end

      it "matches the expected result" do
        expect(default_format).to eq(expected_result)
      end
    end

    context "index includes a unique nulls not distinct clause" do
      let(:indexes) do
        [
          mock_index("index_rails_02e851e3b7", columns: ["id"]),
          mock_index("index_rails_02e851e3b8",
            columns: %w[firstname surname],
            unique: true,
            nulls_not_distinct: true)
        ]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
          #  index_rails_02e851e3b8  (firstname,surname) UNIQUE NULLS NOT DISTINCT
        EOS
      end

      it "matches the expected result" do
        expect(default_format).to eq(expected_result)
      end
    end

    describe "#to_yard" do
      let(:indexes) do
        [mock_index("index_rails_02e851e3b7", columns: ["id"])]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
        EOS
      end

      it "returns annotation in yard format" do
        expect(yard_format).to eq(expected_result)
      end
    end

    describe "#to_rdoc" do
      let(:indexes) do
        [mock_index("index_rails_02e851e3b7", columns: ["id"])]
      end

      let(:expected_result) do
        <<~EOS.strip
          #
          # Indexes
          #
          #  index_rails_02e851e3b7  (id)
        EOS
      end

      it "returns annotation in rdoc format" do
        expect(rdoc_format).to eq(expected_result)
      end
    end
  end
end
