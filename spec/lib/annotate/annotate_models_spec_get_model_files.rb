require 'annotate/annotate_models'
require 'annotate/active_record_patch'
require 'active_support/core_ext/string'
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

  describe '.get_model_files' do
    subject { described_class.get_model_files(options) }

    before do
      ARGV.clear

      described_class.model_dir = [model_dir]
    end

    context 'when `model_dir` is valid' do
      let(:model_dir) do
        Files do
          file 'foo.rb'
          dir 'bar' do
            file 'baz.rb'
            dir 'qux' do
              file 'quux.rb'
            end
          end
          dir 'concerns' do
            file 'corge.rb'
          end
        end
      end

      context 'when the model files are not specified' do
        context 'when no option is specified' do
          let(:options) { {} }

          it 'returns all model files under `model_dir` directory' do
            expect(subject).to contain_exactly(
              [model_dir, 'foo.rb'],
              [model_dir, File.join('bar', 'baz.rb')],
              [model_dir, File.join('bar', 'qux', 'quux.rb')]
            )
          end
        end

        context 'when `ignore_model_sub_dir` option is enabled' do
          let(:options) { { ignore_model_sub_dir: true } }

          it 'returns model files just below `model_dir` directory' do
            expect(subject).to contain_exactly([model_dir, 'foo.rb'])
          end
        end
      end

      context 'when the model files are specified' do
        let(:additional_model_dir) { 'additional_model' }
        let(:model_files) do
          [
            File.join(model_dir, 'foo.rb'),
            "./#{File.join(additional_model_dir, 'corge/grault.rb')}" # Specification by relative path
          ]
        end

        before { ARGV.concat(model_files) }

        context 'when no option is specified' do
          let(:options) { {} }

          context 'when all the specified files are in `model_dir` directory' do
            before do
              described_class.model_dir << additional_model_dir
            end

            it 'returns specified files' do
              expect(subject).to contain_exactly(
                [model_dir, 'foo.rb'],
                [additional_model_dir, 'corge/grault.rb']
              )
            end
          end

          context 'when a model file outside `model_dir` directory is specified' do
            it 'exits with the status code' do
              subject
              raise
            rescue SystemExit => e
              expect(e.status).to eq(1)
            end
          end
        end

        context 'when `is_rake` option is enabled' do
          let(:options) { { is_rake: true } }

          it 'returns all model files under `model_dir` directory' do
            expect(subject).to contain_exactly(
              [model_dir, 'foo.rb'],
              [model_dir, File.join('bar', 'baz.rb')],
              [model_dir, File.join('bar', 'qux', 'quux.rb')]
            )
          end
        end
      end
    end

    context 'when `model_dir` is invalid' do
      let(:model_dir) { '/not_exist_path' }
      let(:options) { {} }

      it 'exits with the status code' do
        subject
        raise
      rescue SystemExit => e
        expect(e.status).to eq(1)
      end
    end
  end
end
