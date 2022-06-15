require 'annotate/annotate_models'
require 'annotate/active_record_patch'
require 'active_support/core_ext/string'
require 'files'
require 'tmpdir'

RSpec.describe AnnotateModels do
  unless const_defined?(:MAGIC_COMMENTS)
    MAGIC_COMMENTS = [
      '# encoding: UTF-8',
      '# coding: UTF-8',
      '# -*- coding: UTF-8 -*-',
      '#encoding: utf-8',
      '# encoding: utf-8',
      '# -*- encoding : utf-8 -*-',
      "# encoding: utf-8\n# frozen_string_literal: true",
      "# frozen_string_literal: true\n# encoding: utf-8",
      '# frozen_string_literal: true',
      '#frozen_string_literal: false',
      '# -*- frozen_string_literal : true -*-'
    ].freeze
  end

  def mock_index(name, params = {})
    double('IndexKeyDefinition',
           name: name,
           columns: params[:columns] || [],
           unique: params[:unique] || false,
           orders: params[:orders] || {},
           where: params[:where],
           using: params[:using])
  end

  def mock_foreign_key(name, from_column, to_table, to_column = 'id', constraints = {})
    double('ForeignKeyDefinition',
           name: name,
           column: from_column,
           to_table: to_table,
           primary_key: to_column,
           on_delete: constraints[:on_delete],
           on_update: constraints[:on_update])
  end

  def mock_connection(indexes = [], foreign_keys = [])
    double('Conn',
           indexes: indexes,
           foreign_keys: foreign_keys,
           supports_foreign_keys?: true)
  end

  def mock_class(table_name, primary_key, columns, indexes = [], foreign_keys = [])
    options = {
      connection: mock_connection(indexes, foreign_keys),
      table_exists?: true,
      table_name: table_name,
      primary_key: primary_key,
      column_names: columns.map { |col| col.name.to_s },
      columns: columns,
      column_defaults: columns.map { |col| [col.name, col.default] }.to_h,
      table_name_prefix: ''
    }

    double('An ActiveRecord class', options)
  end

  def mock_column(name, type, options = {})
    default_options = {
      limit: nil,
      null: false,
      default: nil,
      sql_type: type
    }

    stubs = default_options.dup
    stubs.merge!(options)
    stubs[:name] = name
    stubs[:type] = type

    double('Column', stubs)
  end

  describe '.resolve_filename' do
    subject do
      described_class.resolve_filename(filename_template, model_name, table_name)
    end

    context 'When model_name is "example_model" and table_name is "example_models"' do
      let(:model_name) { 'example_model' }
      let(:table_name) { 'example_models' }

      context "when filename_template is 'test/unit/%MODEL_NAME%_test.rb'" do
        let(:filename_template) { 'test/unit/%MODEL_NAME%_test.rb' }

        it 'returns the test path for a model' do
          expect(subject).to eq 'test/unit/example_model_test.rb'
        end
      end

      context "when filename_template is '/foo/bar/%MODEL_NAME%/testing.rb'" do
        let(:filename_template) { '/foo/bar/%MODEL_NAME%/testing.rb' }

        it 'returns the additional glob' do
          expect(subject).to eq '/foo/bar/example_model/testing.rb'
        end
      end

      context "when filename_template is '/foo/bar/%PLURALIZED_MODEL_NAME%/testing.rb'" do
        let(:filename_template) { '/foo/bar/%PLURALIZED_MODEL_NAME%/testing.rb' }

        it 'returns the additional glob' do
          expect(subject).to eq '/foo/bar/example_models/testing.rb'
        end
      end

      context "when filename_template is 'test/fixtures/%TABLE_NAME%.yml'" do
        let(:filename_template) { 'test/fixtures/%TABLE_NAME%.yml' }

        it 'returns the fixture path for a model' do
          expect(subject).to eq 'test/fixtures/example_models.yml'
        end
      end
    end

    context 'When model_name is "parent/child" and table_name is "parent_children"' do
      let(:model_name) { 'parent/child' }
      let(:table_name) { 'parent_children' }

      context "when filename_template is 'test/fixtures/%PLURALIZED_MODEL_NAME%.yml'" do
        let(:filename_template) { 'test/fixtures/%PLURALIZED_MODEL_NAME%.yml' }

        it 'returns the fixture path for a nested model' do
          expect(subject).to eq 'test/fixtures/parent/children.yml'
        end
      end
    end
  end
end
