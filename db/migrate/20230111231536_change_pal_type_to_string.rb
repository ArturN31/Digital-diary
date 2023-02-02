class ChangePalTypeToString < ActiveRecord::Migration[7.0]
  def change
    change_column(:user_profiles, :user_pal_value, :string)
  end
end
