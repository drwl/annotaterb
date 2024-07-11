class AddIndexToTestNullFalse < ActiveRecord::Migration[7.0]
  def change
    add_index :test_null_falses, :date
    add_index :test_null_falses, [:boolean, :integer], name: "by_compound_bool_and_int"
  end
end
