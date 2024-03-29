# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_01_11_231536) do
  create_table "entries", force: :cascade do |t|
    t.string "food_name"
    t.integer "food_upc_code"
    t.string "food_quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "food_meal_type"
    t.float "food_calories"
    t.float "food_protein"
    t.float "food_carbohydrates"
    t.float "food_fats"
    t.float "food_fibre"
    t.integer "user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer "user_weight"
    t.integer "user_height"
    t.integer "user_age"
    t.string "user_gender"
    t.string "user_pal_value"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_min_calories"
    t.integer "user_max_calories"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "user_profiles", "users"
end
