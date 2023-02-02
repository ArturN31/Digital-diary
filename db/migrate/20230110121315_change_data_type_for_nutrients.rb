class ChangeDataTypeForNutrients < ActiveRecord::Migration[7.0]
  def change
    change_column(:entries, :food_calories, :float)
    change_column(:entries, :food_protein, :float)
    change_column(:entries, :food_carbohydrates, :float)
    change_column(:entries, :food_fibre, :float)
    change_column(:entries, :food_fats, :float)
  end
end
