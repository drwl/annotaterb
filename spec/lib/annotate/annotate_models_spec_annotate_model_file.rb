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

  describe '.annotate_model_file' do
    subject do
      described_class.annotate_model_file([], 'foo.rb', nil, {})
    end

    before do
      class Foo < ActiveRecord::Base; end
      allow(described_class).to receive(:get_model_class).with('foo.rb').and_return(Foo)
      allow(Foo).to receive(:table_exists?).and_return(false)
    end

    after { Object.send :remove_const, 'Foo' }

    it 'skips attempt to annotate if no table exists for model' do
      expect(subject).to eq nil
    end

    context 'with a non-class' do
      before do
        NotAClass = 'foo'.freeze # rubocop:disable Naming/ConstantName
        allow(described_class).to receive(:get_model_class).with('foo.rb').and_return(NotAClass)
      end

      after { Object.send :remove_const, 'NotAClass' }

      it "doesn't output an error" do
        expect { subject }.not_to output.to_stderr
      end
    end
  end
end
