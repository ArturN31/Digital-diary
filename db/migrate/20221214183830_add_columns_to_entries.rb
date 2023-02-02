class AddColumnsToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :food_calories, :integer
    add_column :entries, :food_protein, :integer
    add_column :entries, :food_carbohydrates, :integer
    add_column :entries, :food_fats, :integer
    add_column :entries, :food_fibre, :integer
  end
end
