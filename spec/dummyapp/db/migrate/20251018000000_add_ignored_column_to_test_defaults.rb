# frozen_string_literal: true

class AddIgnoredColumnToTestDefaults < ActiveRecord::Migration["#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"]
  def change
    add_column :test_defaults, :ignored_column, :string
  end
end
