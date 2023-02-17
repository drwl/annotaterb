# encoding: utf-8
require 'annotate/annotate_models'
require 'annotate/active_record_patch'
require 'active_support/core_ext/string'
require 'files'
require 'tmpdir'

RSpec.describe AnnotateModels do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  describe 'annotating a file' do
    before do
      @model_dir = Dir.mktmpdir('annotate_models')
      (@model_file_name, @file_content) = write_model 'user.rb', <<~EOS
        class User < ActiveRecord::Base
        end
      EOS

      @klass = mock_class(:users,
                          :id,
                          [
                            mock_column(:id, :integer),
                            mock_column(:name, :string, limit: 50)
                          ])
      @schema_info = AnnotateModels::SchemaInfo.generate(@klass, '== Schema Info')
      Annotate::Helpers.reset_options(Annotate::Constants::ALL_ANNOTATE_OPTIONS)
    end

    def write_model(file_name, file_content)
      fname = File.join(@model_dir, file_name)
      FileUtils.mkdir_p(File.dirname(fname))
      File.open(fname, 'wb') { |f| f.write file_content }

      [fname, file_content]
    end

    def annotate_one_file(options = {})
      Annotate.set_defaults(options)
      options = Annotate.setup_options(options)
      AnnotateModels.annotate_one_file(@model_file_name, @schema_info, :position_in_class, options)

      # Wipe settings so the next call will pick up new values...
      Annotate.instance_variable_set('@has_set_defaults', false)
      Annotate::Constants::POSITION_OPTIONS.each { |key| ENV[key.to_s] = nil }
      Annotate::Constants::FLAG_OPTIONS.each { |key| ENV[key.to_s] = nil }
      Annotate::Constants::PATH_OPTIONS.each { |key| ENV[key.to_s] = nil }
    end

    context "with 'before'" do
      let(:position) { 'before' }

      it "should put annotation before class if :position == 'before'" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@schema_info}#{@file_content}")
      end
    end

    context "with :before" do
      let(:position) { :before }

      it "should put annotation before class if :position == :before" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@schema_info}#{@file_content}")
      end
    end

    context "with 'top'" do
      let(:position) { 'top' }

      it "should put annotation before class if :position == 'top'" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@schema_info}#{@file_content}")
      end
    end

    context "with :top" do
      let(:position) { :top }

      it "should put annotation before class if :position == :top" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@schema_info}#{@file_content}")
      end
    end

    context "with 'after'" do
      let(:position) { 'after' }

      it "should put annotation after class if position: 'after'" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@file_content}\n#{@schema_info}")
      end
    end

    context "with :after" do
      let(:position) { :after }

      it "should put annotation after class if position: :after" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@file_content}\n#{@schema_info}")
      end
    end

    context "with 'bottom'" do
      let(:position) { 'bottom' }

      it "should put annotation after class if position: 'bottom'" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@file_content}\n#{@schema_info}")
      end
    end

    context "with :bottom" do
      let(:position) { :bottom }

      it "should put annotation after class if position: :bottom" do
        annotate_one_file position: position
        expect(File.read(@model_file_name))
          .to eq("#{@file_content}\n#{@schema_info}")
      end
    end

    it 'should wrap annotation if wrapper is specified' do
      annotate_one_file wrapper_open: 'START', wrapper_close: 'END'
      expect(File.read(@model_file_name))
        .to eq("# START\n#{@schema_info}# END\n#{@file_content}")
    end

    describe 'with existing annotation' do
      context 'of a foreign key' do
        before do
          klass = mock_class(:users,
                             :id,
                             [
                               mock_column(:id, :integer),
                               mock_column(:foreign_thing_id, :integer)
                             ],
                             [],
                             [
                               mock_foreign_key('fk_rails_cf2568e89e',
                                                'foreign_thing_id',
                                                'foreign_things',
                                                'id',
                                                on_delete: :cascade)
                             ])
          @schema_info = AnnotateModels::SchemaInfo.generate(klass, '== Schema Info', show_foreign_keys: true)
          annotate_one_file
        end

        it 'should update foreign key constraint' do
          klass = mock_class(:users,
                             :id,
                             [
                               mock_column(:id, :integer),
                               mock_column(:foreign_thing_id, :integer)
                             ],
                             [],
                             [
                               mock_foreign_key('fk_rails_cf2568e89e',
                                                'foreign_thing_id',
                                                'foreign_things',
                                                'id',
                                                on_delete: :restrict)
                             ])
          @schema_info = AnnotateModels::SchemaInfo.generate(klass, '== Schema Info', show_foreign_keys: true)
          annotate_one_file
          expect(File.read(@model_file_name)).to eq("#{@schema_info}#{@file_content}")
        end
      end
    end

    describe 'with existing annotation => :before' do
      before do
        annotate_one_file position: :before
        another_schema_info = AnnotateModels::SchemaInfo.generate(mock_class(:users, :id, [mock_column(:id, :integer)]), '== Schema Info')
        @schema_info = another_schema_info
      end

      it 'should retain current position' do
        annotate_one_file
        expect(File.read(@model_file_name)).to eq("#{@schema_info}#{@file_content}")
      end

      it 'should retain current position even when :position is changed to :after' do
        annotate_one_file position: :after
        expect(File.read(@model_file_name)).to eq("#{@schema_info}#{@file_content}")
      end

      it 'should change position to :after when force: true' do
        annotate_one_file position: :after, force: true
        expect(File.read(@model_file_name)).to eq("#{@file_content}\n#{@schema_info}")
      end
    end

    describe 'with existing annotation => :after' do
      before do
        annotate_one_file position: :after
        another_schema_info = AnnotateModels::SchemaInfo.generate(mock_class(:users, :id, [mock_column(:id, :integer)]), '== Schema Info')
        @schema_info = another_schema_info
      end

      it 'should retain current position' do
        annotate_one_file
        expect(File.read(@model_file_name)).to eq("#{@file_content}\n#{@schema_info}")
      end

      it 'should retain current position even when :position is changed to :before' do
        annotate_one_file position: :before
        expect(File.read(@model_file_name)).to eq("#{@file_content}\n#{@schema_info}")
      end

      it 'should change position to :before when force: true' do
        annotate_one_file position: :before, force: true
        expect(File.read(@model_file_name)).to eq("#{@schema_info}#{@file_content}")
      end
    end

    it 'should skip columns with option[:ignore_columns] set' do
      output = AnnotateModels::SchemaInfo.generate(@klass, '== Schema Info',
                                                   :ignore_columns => '(id|updated_at|created_at)')
      expect(output.match(/id/)).to be_nil
    end

    it 'works with namespaced models (i.e. models inside modules/subdirectories)' do
      (model_file_name, file_content) = write_model 'foo/user.rb', <<~EOS
        class Foo::User < ActiveRecord::Base
        end
      EOS

      klass = mock_class(:'foo_users',
                         :id,
                         [
                           mock_column(:id, :integer),
                           mock_column(:name, :string, limit: 50)
                         ])
      schema_info = AnnotateModels::SchemaInfo.generate(klass, '== Schema Info')
      AnnotateModels.annotate_one_file(model_file_name, schema_info, position: :before)
      expect(File.read(model_file_name)).to eq("#{schema_info}#{file_content}")
    end

    it 'should not touch magic comments' do
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        write_model 'user.rb', <<~EOS
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

    it 'adds an empty line between magic comments and annotation (position :before)' do
      content = "class User < ActiveRecord::Base\nend\n"
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        model_file_name, = write_model 'user.rb', "#{magic_comment}\n#{content}"

        annotate_one_file position: :before
        schema_info = AnnotateModels::SchemaInfo.generate(@klass, '== Schema Info')

        expect(File.read(model_file_name)).to eq("#{magic_comment}\n\n#{schema_info}#{content}")
      end
    end

    it 'only keeps a single empty line around the annotation (position :before)' do
      content = "class User < ActiveRecord::Base\nend\n"
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        schema_info = AnnotateModels::SchemaInfo.generate(@klass, '== Schema Info')
        model_file_name, = write_model 'user.rb', "#{magic_comment}\n\n\n\n#{content}"

        annotate_one_file position: :before

        expect(File.read(model_file_name)).to eq("#{magic_comment}\n\n#{schema_info}#{content}")
      end
    end

    it 'does not change whitespace between magic comments and model file content (position :after)' do
      content = "class User < ActiveRecord::Base\nend\n"
      AnnotateTestConstants::MAGIC_COMMENTS.each do |magic_comment|
        model_file_name, = write_model 'user.rb', "#{magic_comment}\n#{content}"

        annotate_one_file position: :after
        schema_info = AnnotateModels::SchemaInfo.generate(@klass, '== Schema Info')

        expect(File.read(model_file_name)).to eq("#{magic_comment}\n#{content}\n#{schema_info}")
      end
    end

    describe "if a file can't be annotated" do
      before do
        allow(AnnotateModels).to receive(:get_loaded_model_by_path).with('user').and_return(nil)

        write_model('user.rb', <<~EOS)
          class User < ActiveRecord::Base
            raise "oops"
          end
        EOS
      end

      it 'displays just the error message with trace disabled (default)' do
        expect { AnnotateModels.do_annotations model_dir: @model_dir, is_rake: true }.to output(a_string_including("Unable to annotate #{@model_dir}/user.rb: oops")).to_stderr

        # TODO: Find another way of testing trace without hardcoding the file name as part of the spec
        # expect { AnnotateModels.do_annotations model_dir: @model_dir, is_rake: true }.not_to output(a_string_including('/spec/annotate/annotate_models_spec.rb:')).to_stderr
      end

      it 'displays the error message and stacktrace with trace enabled' do
        expect { AnnotateModels.do_annotations model_dir: @model_dir, is_rake: true, trace: true }.to output(a_string_including("Unable to annotate #{@model_dir}/user.rb: oops")).to_stderr

        # TODO: Find another way of testing trace without hardcoding the file name as part of the spec
        # expect { AnnotateModels.do_annotations model_dir: @model_dir, is_rake: true, trace: true }.to output(a_string_including('/spec/lib/annotate/annotate_models_spec.rb:')).to_stderr
      end
    end

    describe "if a file can't be deannotated" do
      before do
        allow(AnnotateModels).to receive(:get_loaded_model_by_path).with('user').and_return(nil)

        write_model('user.rb', <<~EOS)
          class User < ActiveRecord::Base
            raise "oops"
          end
        EOS
      end

      it 'displays just the error message with trace disabled (default)' do
        expect { AnnotateModels.remove_annotations model_dir: @model_dir, is_rake: true }.to output(a_string_including("Unable to deannotate #{@model_dir}/user.rb: oops")).to_stderr
        expect { AnnotateModels.remove_annotations model_dir: @model_dir, is_rake: true }.not_to output(a_string_including("/user.rb:2:in `<class:User>'")).to_stderr
      end

      it 'displays the error message and stacktrace with trace enabled' do
        expect { AnnotateModels.remove_annotations model_dir: @model_dir, is_rake: true, trace: true }.to output(a_string_including("Unable to deannotate #{@model_dir}/user.rb: oops")).to_stderr
        expect { AnnotateModels.remove_annotations model_dir: @model_dir, is_rake: true, trace: true }.to output(a_string_including("/user.rb:2:in `<class:User>'")).to_stderr
      end
    end
  end
end
