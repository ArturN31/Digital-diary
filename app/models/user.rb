class User < ApplicationRecord
  has_many :entries #1 error prohibited this entry from being saved: User must exist
  has_secure_password
end
