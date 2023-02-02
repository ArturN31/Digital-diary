class User < ApplicationRecord
  has_many :entries
  has_many :user_profiles
  has_secure_password
  
end
