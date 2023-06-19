RSpec.describe AnnotateRb::ModelAnnotator::Annotator do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  describe "annotating a file" do
    let(:options) { AnnotateRb::Options.new({}) }

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

    describe "with existing annotation => :before" do
      before do
        annotate_one_file position: :before
        another_schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(
          mock_class(:users, :id, [mock_column("id", :integer)]),
          options
        ).build

        @schema_info = another_schema_info
      end

      it "should change position to :after when force: true" do
        annotate_one_file position: :after, force: true
        expect(File.read(@model_file_name)).to eq("#{@file_content}\n#{@schema_info}")
      end
    end

    describe "with existing annotation => :after" do
      before do
        annotate_one_file position: :after
        another_schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(
          mock_class(:users, :id, [mock_column("id", :integer)]),
          options
        ).build

        @schema_info = another_schema_info
      end

      it "should change position to :before when force: true" do
        annotate_one_file position: :before, force: true
        expect(File.read(@model_file_name)).to eq("#{@schema_info}#{@file_content}")
      end
    end

    it "should skip columns with option[:ignore_columns] set" do
      options = AnnotateRb::Options.new({ignore_columns: "(id|updated_at|created_at)"})
      output = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(
        @klass, options
      ).build

      expect(output.match(/id/)).to be_nil
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

      AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(model_file_name, schema_info, position: :before)
      expect(File.read(model_file_name)).to eq("#{schema_info}#{file_content}")
    end

    it "should not touch magic comments" do
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        write_model "user.rb", <<~EOS
          #{magic_comment}
          class User < ActiveRecord::Base
          end
        EOS

        annotate_one_file position: :before

        lines = magic_comment.split("\n")
        File.open @model_file_name do |file|
          lines.count.times do |index|
            expect(file.readline).to eq "#{lines[index]}\n"
          end
        end
      end
    end

    it "adds an empty line between magic comments and annotation (position :before)" do
      content = "class User < ActiveRecord::Base\nend\n"
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        model_file_name, = write_model "user.rb", "#{magic_comment}\n#{content}"

        annotate_one_file position: :before
        schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(@klass, options).build

        expect(File.read(model_file_name)).to eq("#{magic_comment}\n\n#{schema_info}#{content}")
      end
    end

    it "only keeps a single empty line around the annotation (position :before)" do
      content = "class User < ActiveRecord::Base\nend\n"
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(@klass, options).build
        model_file_name, = write_model "user.rb", "#{magic_comment}\n\n\n\n#{content}"

        annotate_one_file position: :before

        expect(File.read(model_file_name)).to eq("#{magic_comment}\n\n#{schema_info}#{content}")
      end
    end

    it "does not change whitespace between magic comments and model file content (position :after)" do
      content = "class User < ActiveRecord::Base\nend\n"
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        model_file_name, = write_model "user.rb", "#{magic_comment}\n#{content}"

        annotate_one_file position: :after
        schema_info = AnnotateRb::ModelAnnotator::AnnotationBuilder.new(@klass, options).build

        expect(File.read(model_file_name)).to eq("#{magic_comment}\n#{content}\n#{schema_info}")
      end
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
        options = AnnotateRb::Options.from({model_dir: @model_dir, is_rake: true})

        expect { described_class.do_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr

        # TODO: Find another way of testing trace without hardcoding the file name as part of the spec
        # expect { described_class.do_annotations(options) }.not_to output(a_string_including('/spec/annotate/annotate_models_spec.rb:')).to_stderr
      end

      it "displays the error message and stacktrace with trace enabled" do
        options = AnnotateRb::Options.from({model_dir: @model_dir, is_rake: true, trace: true})
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
        options = AnnotateRb::Options.from({model_dir: @model_dir, is_rake: true})

        expect { described_class.remove_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr
        expect { described_class.remove_annotations(options) }.not_to output(a_string_including("/user.rb:2:in `<class:User>'")).to_stderr
      end

      it "displays the error message and stacktrace with trace enabled" do
        options = AnnotateRb::Options.from({model_dir: @model_dir, is_rake: true, trace: true})

        expect { described_class.remove_annotations(options) }.to output(a_string_including("Unable to process #{@model_dir}/user.rb: oops")).to_stderr
        expect { described_class.remove_annotations(options) }.to output(a_string_including("/user.rb:2:in `<class:User>'")).to_stderr
      end
    end
  end
end
