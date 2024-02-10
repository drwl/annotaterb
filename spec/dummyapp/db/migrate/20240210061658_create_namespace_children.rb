class CreateNamespaceChildren < ActiveRecord::Migration[7.0]
  def change
    create_table :namespace_test_children do |t|
      t.string :name
      t.integer :age

      t.timestamps
    end
  end
end
