json.extract! user_profile, :id, :user_weight, :user_height, :user_age, :user_gender, :user_pal_value, :user_min_calories, :user_max_calories, :user_id, :created_at, :updated_at
json.url user_profile_url(user_profile, format: :json)
