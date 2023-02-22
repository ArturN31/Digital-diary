class ChangeIntegerLimitForUpc < ActiveRecord::Migration[7.0]
  def change
    change_column :entries, :food_upc_code, :integer, limit: 8
  end
end
