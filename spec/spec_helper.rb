require 'bundler/setup'
require 'rake'
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/subclasses'
require 'active_support/core_ext/string/inflections'
require 'annotate'
require 'annotate/parser'
require 'annotate/helpers'
require 'annotate/constants'
require 'files'
require 'byebug'

require 'annotate_rb'

def mock_index(name, params = {})
  double('IndexKeyDefinition',
         name:    name,
         columns: params[:columns] || [],
         unique:  params[:unique] || false,
         orders:  params[:orders] || {},
         where:   params[:where],
         using:   params[:using])
end

def mock_foreign_key(name, from_column, to_table, to_column = 'id', constraints = {})
  double('ForeignKeyDefinition',
         name:        name,
         column:      from_column,
         to_table:    to_table,
         primary_key: to_column,
         on_delete:   constraints[:on_delete],
         on_update:   constraints[:on_update])
end

def mock_connection(indexes = [], foreign_keys = [])
  double('Conn',
         indexes:      indexes,
         foreign_keys: foreign_keys,
         supports_foreign_keys?: true)
end

def mock_class(table_name, primary_key, columns, indexes = [], foreign_keys = [])
  options = {
    connection:      mock_connection(indexes, foreign_keys),
    table_exists?:   true,
    table_name:      table_name,
    primary_key:     primary_key,
    column_names:    columns.map { |col| col.name.to_s },
    columns:         columns,
    column_defaults: Hash[columns.map { |col| [col.name, col.default] }],
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

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end
