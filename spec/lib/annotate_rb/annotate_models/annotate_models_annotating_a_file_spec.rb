RSpec.describe AnnotateRb::ModelAnnotator::Annotator do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  describe "annotating a file" do
    let(:options) { AnnotateRb::Options.from({position: :before}) }

    before do
      @model_dir = Dir.mktmpdir("annotate_models")
      (@model_file_name, @file_content) = write_model "user.rb", <<~EOS
        class User < ActiveRecord::Base
        end
      EOS

      @klass = mock_class(:users,
        :id,
        [
          mock_column("id", :integer),
          mock_column("name", :string, limit: 50)
        ])
      @schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(@klass, options).build
    end

    it "works with namespaced models (i.e. models inside modules/subdirectories)" do
      (model_file_name, file_content) = write_model "foo/user.rb", <<~EOS
        class Foo::User < ActiveRecord::Base
        end
      EOS

      klass = mock_class(:foo_users,
        :id,
        [
          mock_column("id", :integer),
          mock_column("name", :string, limit: 50)
        ])
      schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(
        klass,
        options
      ).build

      AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(model_file_name, schema_info, :position_in_class, options)
      expect(File.read(model_file_name)).to eq("#{schema_info}#{file_content}")
    end

    describe "if a file can't be annotated" do
      before do
        allow(AnnotateRb::ModelAnnotator::ModelClassGetter).to receive(:get_loaded_model_by_path).with("user").and_return(nil)

        write_model("user.rb", <<~EOS)
          class User < ActiveRecord::Base
            raise "oops"
          end
        EOS
      end

      it "displays just the error message with trace disabled (default)" do
        options = AnnotateRb::Options.from({model_dir: @model_dir}, {working_args: []})

        expect { described_class.do_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr

        # TODO: Find another way of testing trace without hardcoding the file name as part of the spec
        # expect { described_class.do_annotations(options) }.not_to output(a_string_including('/spec/annotate/annotate_models_spec.rb:')).to_stderr
      end

      it "displays the error message and stacktrace with trace enabled" do
        options = AnnotateRb::Options.from({model_dir: @model_dir, trace: true}, {working_args: []})
        expect { described_class.do_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr

        # TODO: Find another way of testing trace without hardcoding the file name as part of the spec
        # expect { described_class.do_annotations(options) }.to output(a_string_including('/spec/lib/annotate/annotate_models_spec.rb:')).to_stderr
      end
    end

    describe "if a file can't be deannotated" do
      before do
        allow(AnnotateRb::ModelAnnotator::ModelClassGetter).to receive(:get_loaded_model_by_path).with("user").and_return(nil)

        write_model("user.rb", <<~EOS)
          class User < ActiveRecord::Base
            raise "oops"
          end
        EOS
      end

      it "displays just the error message with trace disabled (default)" do
        options = AnnotateRb::Options.from({model_dir: @model_dir}, {working_args: []})

        expect { described_class.remove_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr
        expect { described_class.remove_annotations(options) }.not_to output(a_string_including("/user.rb:2:in `<class:User>'")).to_stderr
      end

      it "displays the error message and stacktrace with trace enabled" do
        options = AnnotateRb::Options.from({model_dir: @model_dir, trace: true}, {working_args: []})

        expect { described_class.remove_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr
        expect { described_class.remove_annotations(options) }.to output(a_string_including("/user.rb:2:in `<class:User>'")).to_stderr
      end
    end
  end
end
