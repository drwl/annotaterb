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
        let(:additional_model_dir) { Dir.mktmpdir }
        let(:model_files) do
          [
            File.join(model_dir, "foo.rb"),
            File.join(additional_model_dir, "corge/grault.rb")
          ]
        end

        before do
          FileUtils.mkdir_p(File.join(additional_model_dir, "corge"))
          FileUtils.touch(File.join(additional_model_dir, "corge", "grault.rb"))
        end

        after do
          FileUtils.remove_entry(additional_model_dir) if additional_model_dir && Dir.exist?(additional_model_dir)
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
              expect($stderr.string).to include("The specified file(s) could not be found in any directory matching patterns")
              expect($stderr.string).to include(model_dir)
              expect($stderr.string).to include(File.join(additional_model_dir, "corge/grault.rb"))
            end
          end
        end

        context "when `model_dir` contains glob patterns" do
          around do |example|
            tmpdir = Dir.mktmpdir
            Dir.chdir(tmpdir) do
              example.run
            end
          ensure
            FileUtils.remove_entry(tmpdir) if tmpdir && Dir.exist?(tmpdir)
          end

          let(:core_app_models_dir) { File.join("apps", "core_app", "models") }
          let(:admin_app_models_dir) { File.join("apps", "admin_app", "models") }
          let(:standard_models_dir) { "standard_models" }
          let(:deep_models_dir) { File.join("apps", "admin_app", "modules", "core", "models") }

          before do
            FileUtils.mkdir_p(core_app_models_dir)
            FileUtils.touch(File.join(core_app_models_dir, "user.rb"))
            FileUtils.mkdir_p(File.join(core_app_models_dir, "concerns"))
            FileUtils.touch(File.join(core_app_models_dir, "concerns", "shared.rb"))

            FileUtils.mkdir_p(admin_app_models_dir)
            FileUtils.touch(File.join(admin_app_models_dir, "product.rb"))
            FileUtils.mkdir_p(File.join(admin_app_models_dir, "nested"))
            FileUtils.touch(File.join(admin_app_models_dir, "nested", "item.rb"))

            FileUtils.mkdir_p(standard_models_dir)
            FileUtils.touch(File.join(standard_models_dir, "order.rb"))

            FileUtils.mkdir_p(deep_models_dir)
            FileUtils.touch(File.join(deep_models_dir, "payment.rb"))
          end

          context "when using a simple star glob" do
            let(:base_options) { {model_dir: ["apps/*/models"]} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

            it "finds models in matching directories" do
              is_expected.to contain_exactly(
                [core_app_models_dir, "user.rb"],
                [admin_app_models_dir, "product.rb"],
                [admin_app_models_dir, File.join("nested", "item.rb")]
              )
            end
          end

          context "when using a recursive glob" do
            let(:base_options) { {model_dir: ["apps/**/models"]} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

            it "finds models in all matching directories recursively" do
              is_expected.to contain_exactly(
                [core_app_models_dir, "user.rb"],
                [admin_app_models_dir, "product.rb"],
                [admin_app_models_dir, File.join("nested", "item.rb")],
                [deep_models_dir, "payment.rb"]
              )
            end
          end

          context "when combining globs and regular paths" do
            let(:base_options) { {model_dir: ["apps/core_app/models", standard_models_dir]} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

            it "finds models in all specified locations" do
              is_expected.to contain_exactly(
                [core_app_models_dir, "user.rb"],
                [standard_models_dir, "order.rb"]
              )
            end
          end

          context "when using glob and `ignore_model_sub_dir` is true" do
            let(:base_options) { {model_dir: ["apps/*/models"], ignore_model_sub_dir: true} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

            it "returns only top-level model files in matching directories" do
              is_expected.to contain_exactly(
                [core_app_models_dir, "user.rb"],
                [admin_app_models_dir, "product.rb"]
              )
            end
          end

          context "when a glob matches no directories" do
            let(:base_options) { {model_dir: ["nonexistent/**/models"]} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

            it { is_expected.to be_empty }
          end

          context "when the model files are specified and `model_dir` uses globs" do
            let(:model_files) do
              [
                File.join(core_app_models_dir, "user.rb"),
                File.join(standard_models_dir, "order.rb")
              ]
            end
            let(:base_options) { {model_dir: ["apps/*/models", standard_models_dir]} }
            let(:options) { AnnotateRb::Options.new(base_options, {working_args: model_files}) }

            it "returns only the specified files found within the globbed directories" do
              is_expected.to contain_exactly(
                [core_app_models_dir, "user.rb"],
                [standard_models_dir, "order.rb"]
              )
            end

            context "when a specified file is outside the matched glob directories" do
              let(:outside_file_rel_path) { File.join("outside", "other.rb") }
              let(:model_files_with_outside) { model_files + [outside_file_rel_path] }
              let(:options) { AnnotateRb::Options.new(base_options, {working_args: model_files_with_outside}) }

              before do
                FileUtils.mkdir_p("outside")
                FileUtils.touch(outside_file_rel_path)
              end

              it "writes an error to $stderr" do
                subject
                expect($stderr.string).to include("The specified file(s) could not be found in any directory matching patterns")
                expect($stderr.string).to include("'apps/*/models', '#{standard_models_dir}'")
                expect($stderr.string).to include(outside_file_rel_path)
              end

              it "returns only the files found within the matched directories" do
                is_expected.to contain_exactly(
                  [core_app_models_dir, "user.rb"],
                  [standard_models_dir, "order.rb"]
                )
              end
            end
          end
        end
      end
    end

    context "when `model_dir` is invalid or does not exist" do
      let(:model_dir) { "/path/that/does/not/exist" }
      let(:base_options) { {model_dir: [model_dir]} }
      let(:options) { AnnotateRb::Options.new(base_options, {working_args: []}) }

      it "returns an empty list and does not write to stderr" do
        # Expect no error message to be printed
        expect { subject }.not_to output.to_stderr
        # Expect the result to be an empty array
        is_expected.to be_empty
      end
    end
  end
end
