class AddComplexCasesToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :is_default_false, :boolean, default: false
    add_column :cases, :is_default_true, :boolean, default: true
    add_column :cases, :default_number, :integer, default: 1
    add_column :cases, :default_zero, :integer, default: 0
  end
end
