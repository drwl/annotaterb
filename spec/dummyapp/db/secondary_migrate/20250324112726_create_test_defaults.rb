class CreateTestDefaults < ActiveRecord::Migration[7.0]
  def change
    create_table :test_defaults do |t|
      t.string :string

      t.timestamps
    end
  end
end
