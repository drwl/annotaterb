# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::Annotation::SchemaHeader do
  describe "#to_default" do
    subject { described_class.new(table_name, table_comment, options).to_default }

    let(:table_name) { "users" }
    let(:table_comment) {}
    let :options do
      AnnotateRb::Options.new({})
    end

    let(:expected_header) do
      <<~HEADER.strip
        #
        # Table name: users
        #
      HEADER
    end

    it { is_expected.to eq(expected_header) }

    context "with `with_comment: true`" do
      context "with `with_table_comments: true` and table has comments" do
        let :options do
          AnnotateRb::Options.new({with_comment: true, with_table_comments: true})
        end

        let(:table_comment) { "table_comments" }

        let(:expected_header) do
          <<~HEADER.strip
            #
            # Table name: users(table_comments)
            #
          HEADER
        end

        it "returns the header with the table comment" do
          is_expected.to eq(expected_header)
        end
      end

      context "with `with_table_comments: true` and table does not have comments" do
        let :options do
          AnnotateRb::Options.new({with_comment: true, with_table_comments: true})
        end

        let(:table_comment) {}

        let(:expected_header) do
          <<~HEADER.strip
            #
            # Table name: users
            #
          HEADER
        end

        it "returns the header without table comments" do
          is_expected.to eq(expected_header)
        end
      end

      context "with `with_table_comments: false` and table has comments" do
        let :options do
          AnnotateRb::Options.new({with_comment: true, with_table_comments: false})
        end

        let(:table_comment) { "table_comments" }

        let(:expected_header) do
          <<~HEADER.strip
            #
            # Table name: users
            #
          HEADER
        end

        it "returns the header without the table comment" do
          is_expected.to eq(expected_header)
        end
      end
    end

    context "with `with_comment: false`" do
      context "with `with_table_comments: true` and table has comments" do
        let :options do
          AnnotateRb::Options.new({with_comment: false, with_table_comments: true})
        end

        let(:table_comment) { "table_comments" }

        let(:expected_header) do
          <<~HEADER.strip
            #
            # Table name: users
            #
          HEADER
        end

        it "returns the header without the table comment" do
          is_expected.to eq(expected_header)
        end
      end

      context "with `with_table_comments: false` and table has comments" do
        let :options do
          AnnotateRb::Options.new({with_comment: false, with_table_comments: false})
        end

        let(:table_comment) { "table_comments" }

        let(:expected_header) do
          <<~HEADER.strip
            #
            # Table name: users
            #
          HEADER
        end

        it "returns the header without the table comment" do
          is_expected.to eq(expected_header)
        end
      end
    end
  end

  describe "#to_markdown" do
    subject { described_class.new(table_name, table_comment, options).to_markdown }

    let(:table_name) { "users" }
    let(:table_comment) {}
    let :options do
      AnnotateRb::Options.new({})
    end

    let(:expected_header) do
      <<~HEADER.strip
        #
        # Table name: `users`
        #
      HEADER
    end

    it { is_expected.to eq(expected_header) }
  end
end
