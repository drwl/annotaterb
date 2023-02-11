class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.integer :count
      t.boolean :status
      t.string :content

      t.timestamps
    end
  end
end
