RSpec.describe AnnotateRb::ModelAnnotator::FileToParserMapper do
  describe ".map" do
    subject { described_class.map(file_name) }
    let(:custom_parser) { AnnotateRb::ModelAnnotator::FileParser::CustomParser }

    context "when it is a ruby file" do
      let(:file_name) { "some_path/script.rb" }

      it { is_expected.to eq(custom_parser) }
    end

    context "when it is a non Ruby file" do
      let(:file_name) { "some_path/some_file.abc" }

      it "raises an error" do
        expect { subject }.to raise_error(described_class::UnsupportedFileTypeError)
      end
    end
  end
end
