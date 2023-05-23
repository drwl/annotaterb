# encoding: utf-8
# frozen_string_literal: true

RSpec.describe AnnotateRb::ModelAnnotator::SingleFileAnnotator do
  include AnnotateTestHelpers
  include AnnotateTestConstants

  describe '.call' do
    describe 'annotating a file without annotations' do
      let(:options) { AnnotateRb::Options.from({}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          class User < ActiveRecord::Base
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ActiveRecord::Base
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir('annotaterb')
        (@model_file_name, _file_content) = write_model('user.rb', starting_file_content)
      end

      it 'writes the annotations to the file' do
        AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe 'annotating a file with old annotations' do
      let(:options) { AnnotateRb::Options.from({}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir('annotaterb')
        (@model_file_name, _file_content) = write_model('user.rb', starting_file_content)
      end

      it 'updates the annotations' do
        AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe 'annotating a file with old annotations and magic comments' do
      let(:options) { AnnotateRb::Options.from({}) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # typed: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # frozen_string_literal: true
          # typed: true
          # == Schema Information
          #
          # Table name: users
          #
          #  id                     :bigint           not null, primary key
          #  name :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir('annotaterb')
        (@model_file_name, _file_content) = write_model('user.rb', starting_file_content)
      end

      it 'updates the annotations' do
        AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end

    describe 'annotating a file with existing column comments' do
      let(:options) { AnnotateRb::Options.from({ with_comment: true }) }
      let(:schema_info) do
        <<~SCHEMA
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #
        SCHEMA
      end
      let(:starting_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                       :integer          not null, primary key
          #  name([sensitivity: low]) :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end
      let(:expected_file_content) do
        <<~FILE
          # == Schema Information
          #
          # Table name: users
          #
          #  id                          :integer          not null, primary key
          #  name([sensitivity: medium]) :string(50)       not null
          #
          class User < ApplicationRecord
          end
        FILE
      end

      before do
        @model_dir = Dir.mktmpdir('annotaterb')
        (@model_file_name, _file_content) = write_model('user.rb', starting_file_content)

        @klass = mock_class(:users,
                            :id,
                            [
                              # Having `comment: nil` for id column is the "correct" test setup
                              # Only MySQL and PostgreSQL adapters support comments AND ModelWrapper#with_comments?
                              # expects the first column to respond to `comment` method before checking the rest.
                              mock_column(:id, :integer, comment: nil),
                              mock_column(:name, :string, limit: 50, comment: '[sensitivity: medium]')
                            ])
      end

      it 'updates the annotations' do
        AnnotateRb::ModelAnnotator::SingleFileAnnotator.call(@model_file_name, schema_info, :position_in_class, options)
        expect(File.read(@model_file_name)).to eq(expected_file_content)
      end
    end
  end
end