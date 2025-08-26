class CreateTestParents < ActiveRecord::Migration[7.1]
  def change
    create_table :test_parents do |t|
      t.string :type
      t.string :something

      t.timestamps
    end
  end
end
