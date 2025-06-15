require "tempfile"

RSpec.describe AnnotateRb::ConfigLoader do
  before do
    expect(AnnotateRb::ConfigFinder).to receive(:find_project_dotfile).and_return(dotfile)
  end

  describe ".load_config" do
    subject { described_class.load_config }

    context "there is no config file" do
      let(:dotfile) { nil }

      it { is_expected.to eq({}) }
    end

    context "there is a plain config file" do
      let(:tempfile) { Tempfile.new("annotaterb") }
      let(:dotfile) { tempfile.path }

      around do |example|
        File.write(tempfile.path, <<~YAML)
          :model_dir:
          - app/models
        YAML
        example.run
        tempfile.unlink
      end

      it "reads the dotfile successfully" do
        expect(subject[:model_dir]).to eq(["app/models"])
      end
    end

    context "the config file has ERB in it" do
      let(:tempfile) { Tempfile.new("annotaterb") }
      let(:dotfile) { tempfile.path }

      around do |example|
        File.write(tempfile.path, <<~YAML)
          <% model_dir = %w[foo/models bar/models baz/models] %>
          :model_dir: <%= model_dir.inspect %>
        YAML
        example.run
        tempfile.unlink
      end

      it "reads the dotfile successfully" do
        expect(subject[:model_dir]).to eq(%w[foo/models bar/models baz/models])
      end
    end
  end
end
