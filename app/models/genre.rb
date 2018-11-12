class Genre < ApplicationRecord
    has_many :user_genres
    has_many :users, through: :user_genres
    has_many :books

    def self.available_genres
        Genre.all.pluck(:name)
    end
end
