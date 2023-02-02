class AddColumnsToUserProfilesToStoreCalories < ActiveRecord::Migration[7.0]
  def change
    add_column :user_profiles, :user_min_calories, :integer
    add_column :user_profiles, :user_max_calories, :integer
  end
end
