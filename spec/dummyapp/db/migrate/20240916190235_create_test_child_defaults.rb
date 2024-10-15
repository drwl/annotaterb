class CreateTestChildDefaults < ActiveRecord::Migration[7.0]
  def change
    create_table :test_child_defaults do |t|
      t.references :test_default, null: false, foreign_key: true

      t.timestamps
    end
  end
end
