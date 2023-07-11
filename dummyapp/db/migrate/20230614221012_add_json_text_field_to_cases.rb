class AddJsonTextFieldToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :json_text_field, :text
  end
end
