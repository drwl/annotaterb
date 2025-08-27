RSpec.describe AnnotateRb::ModelAnnotator::ModelFilesGetter do
  describe ".call" do
    subject { described_class.call(options) }

    before do
      $stdout = StringIO.new
      $stderr = StringIO.new
    end

    after do
      $stdout = STDOUT
      $stderr = STDERR
    end

    context "when `model_dir` is valid" do
      let(:model_dir) do
        dir = Dir.mktmpdir
        FileUtils.touch(File.join(dir, "foo.rb"))
        FileUtils.mkdir_p(File.join(dir, "bar"))
        FileUtils.touch(File.join(dir, "bar", "baz.rb"))
        FileUtils.mkdir_p(File.join(dir, "bar", "qux"))
        FileUtils.touch(File.join(dir, "bar", "qux", "quux.rb"))
        FileUtils.mkdir_p(File.join(dir, "concerns"))
        FileUtils.touch(File.join(dir, "concerns", "corge.rb"))
        dir
      end

      context "when the model files are not specified" do
        context "when no option is specified" do
          let(:base_options) { {model_dir: [model_dir]} }
          let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

          it "returns all model files under `model_dir` directory" do
            is_expected.to contain_exactly(
              [model_dir, "foo.rb"],
              [model_dir, File.join("bar", "baz.rb")],
              [model_dir, File.join("bar", "qux", "quux.rb")]
            )
          end
        end

        context "when `ignore_model_sub_dir` option is enabled" do
          let(:base_options) { {model_dir: [model_dir], ignore_model_sub_dir: true} }
          let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

          it "returns model files just below `model_dir` directory" do
            is_expected.to contain_exactly([model_dir, "foo.rb"])
          end
        end
      end

      context "when the model files are specified" do
        let(:additional_model_dir) { "additional_model" }
        let(:model_files) do
          [
            File.join(model_dir, "foo.rb"),
            "./#{File.join(additional_model_dir, "corge/grault.rb")}" # Specification by relative path
          ]
        end

        context "when no option is specified" do
          let(:base_options) { {model_dir: [model_dir, additional_model_dir]} }
          let(:options) { AnnotateRb::Options.new(base_options, {working_args: model_files}) }

          context "when all the specified files are in `model_dir` directory" do
            it "returns specified files" do
              is_expected.to contain_exactly(
                [model_dir, "foo.rb"],
                [additional_model_dir, "corge/grault.rb"]
              )
            end
          end

          context "when a model file outside `model_dir` directory is specified" do
            let(:base_options) { {model_dir: [model_dir]} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: model_files}) }

            it "writes to $stderr" do
              subject
              expect($stderr.string).to include("The specified file could not be found in directory")
            end
          end
        end
      end
    end

    context "when `model_dir` is invalid" do
      let(:model_dir) { "/not_exist_path" }
      let(:base_options) { {model_dir: [model_dir]} }
      let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

      it "writes to $stderr" do
        subject
        expect($stderr.string).to include("No models found in directory")
      end

      it "returns an empty array" do
        expect(subject).to be_empty
      end
    end

    context "when `model_dir` is the glob pattern" do
      let(:base_options) { {model_dir: ["app/models", "packs/*/app/models"]} }
      let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

      around do |example|
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            FileUtils.mkdir_p(File.join("app", "models"))
            FileUtils.touch(File.join("app", "models", "x.rb"))
            FileUtils.mkdir_p(File.join("packs", "foo", "app", "models"))
            FileUtils.touch(File.join("packs", "foo", "app", "models", "y.rb"))
            FileUtils.mkdir_p(File.join("packs", "bar", "app", "models"))
            FileUtils.touch(File.join("packs", "bar", "app", "models", "z.rb"))

            example.run
          end
        end
      end

      it "returns all model files under directories that matches the glob pattern" do
        is_expected.to contain_exactly(
          ["app/models", "x.rb"],
          ["packs/bar/app/models", "z.rb"],
          ["packs/foo/app/models", "y.rb"]
        )
      end
    end
  end
end
