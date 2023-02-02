class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.string :food_name
      t.integer :food_upc_code
      t.string :food_quantity

      t.timestamps
    end
  end
end
