# frozen_string_literal: true

class AddIntFieldToTestDefaults < ActiveRecord::Migration["#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"]
  def change
    add_column :test_defaults, :int_field, :integer
  end
end
