class AddSimpleBoolToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :simple_bool, :boolean
  end
end
