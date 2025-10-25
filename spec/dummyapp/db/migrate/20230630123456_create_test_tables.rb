# frozen_string_literal: true

class CreateTestTables < ActiveRecord::Migration["#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"]
  def change
    create_table :test_defaults do |t|
      t.boolean :boolean, default: false
      t.date :date, default: '2023-07-04'
      t.datetime :datetime, default: '2023-07-04 12:34:56 UTC'
      t.decimal :decimal, precision: 14, scale: 2, default: BigDecimal('43.21')
      t.float :float, default: 12.34
      t.integer :integer, default: 99
      t.string :string, default: 'hello world!'
      t.string :ignored_column

      t.timestamps
    end

    create_table :test_null_falses do |t|
      t.binary :binary, null: false
      t.boolean :boolean, null: false
      t.date :date, null: false
      t.datetime :datetime, null: false
      t.decimal :decimal, precision: 14, scale: 2, null: false
      t.float :float, null: false
      t.integer :integer, null: false
      t.string :string, null: false
      t.text :text, null: false
      t.timestamp :timestamp, null: false

      t.timestamps
    end
  end
end
