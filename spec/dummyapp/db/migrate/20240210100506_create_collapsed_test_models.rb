class CreateCollapsedTestModels < ActiveRecord::Migration[7.0]
  def change
    create_table :collapsed_test_models do |t|
      t.string :name

      t.timestamps
    end
  end
end
