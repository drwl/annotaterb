# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

if ['mysql2', 'pg', 'sqlite3'].include?(ENV['DATABASE_ADAPTER'])
  require ENV['DATABASE_ADAPTER']
else
  raise 'The environment variable DATABASE_ADAPTER must be one of mysql2, pg, or sqlite3'
end

require 'pry'

require_relative 'test_app/config/environment'

ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
ActiveRecord::Tasks::DatabaseTasks.drop_current
ActiveRecord::Tasks::DatabaseTasks.create_current
ActiveRecord::Tasks::DatabaseTasks.migrate

require 'aruba/rspec'

Aruba.configure do |config|
  config.allow_absolute_paths = true
end
