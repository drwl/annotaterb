class AddSimpleIntFieldToTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :simple_int, :integer
  end
end
