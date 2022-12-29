class AddColumnToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :food_meal_type, :string
  end
end
