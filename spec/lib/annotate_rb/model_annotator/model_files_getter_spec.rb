RSpec.describe AnnotateRb::ModelAnnotator::ModelFilesGetter do
  describe ".call" do
    subject { described_class.call(options) }

    before do
      $stdout = StringIO.new
      $stderr = StringIO.new

      ARGV.clear
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
          let(:options) { AnnotateRb::Options.new(base_options) }

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
          let(:options) { AnnotateRb::Options.new(base_options) }

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

        before { ARGV.concat(model_files) }

        context "when no option is specified" do
          let(:base_options) { {model_dir: [model_dir, additional_model_dir]} }
          let(:options) { AnnotateRb::Options.new(base_options) }

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
            let(:options) { AnnotateRb::Options.new(base_options) }

            it "writes to $stderr" do
              subject
              expect($stderr.string).to include("The specified file could not be found in directory")
            end
          end
        end

        context "when `is_rake` option is enabled" do
          let(:base_options) { {model_dir: [model_dir], is_rake: true} }
          let(:options) { AnnotateRb::Options.new(base_options) }

          it "returns all model files under `model_dir` directory" do
            is_expected.to contain_exactly(
              [model_dir, "foo.rb"],
              [model_dir, File.join("bar", "baz.rb")],
              [model_dir, File.join("bar", "qux", "quux.rb")]
            )
          end
        end
      end
    end

    context "when `model_dir` is invalid" do
      let(:model_dir) { "/not_exist_path" }
      let(:base_options) { {model_dir: [model_dir]} }
      let(:options) { AnnotateRb::Options.new(base_options) }

      it "writes to $stderr" do
        subject
        expect($stderr.string).to include("No models found in directory")
      end
    end
  end
end
