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

  describe '.quote' do
    subject do
      described_class.quote(value)
    end

    context 'when the argument is nil' do
      let(:value) { nil }

      it 'returns string "NULL"' do
        expect(subject).to eq('NULL')
      end
    end

    context 'when the argument is true' do
      let(:value) { true }

      it 'returns string "TRUE"' do
        expect(subject).to eq('TRUE')
      end
    end

    context 'when the argument is false' do
      let(:value) { false }

      it 'returns string "FALSE"' do
        expect(subject).to eq('FALSE')
      end
    end

    context 'when the argument is an integer' do
      let(:value) { 25 }

      it 'returns the integer as a string' do
        expect(subject).to eq('25')
      end
    end

    context 'when the argument is a float number' do
      context 'when the argument is like 25.6' do
        let(:value) { 25.6 }

        it 'returns the float number as a string' do
          expect(subject).to eq('25.6')
        end
      end

      context 'when the argument is like 1e-20' do
        let(:value) { 1e-20 }

        it 'returns the float number as a string' do
          expect(subject).to eq('1.0e-20')
        end
      end
    end

    context 'when the argument is a BigDecimal number' do
      let(:value) { BigDecimal('1.2') }

      it 'returns the float number as a string' do
        expect(subject).to eq('1.2')
      end
    end

    context 'when the argument is an array' do
      let(:value) { [BigDecimal('1.2')] }

      it 'returns an array of which elements are converted to string' do
        expect(subject).to eq(['1.2'])
      end
    end
  end
end
