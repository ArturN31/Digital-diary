class CreateUserProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_profiles do |t|
      t.integer :user_weight
      t.integer :user_height
      t.integer :user_age
      t.string :user_gender
      t.integer :user_pal_value
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
