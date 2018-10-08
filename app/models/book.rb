class Book < ApplicationRecord
    has_and_belongs_to_many :users
    has_many :comments
    has_many :ratings
end
