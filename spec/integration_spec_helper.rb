# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

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
