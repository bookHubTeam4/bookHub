class Genre < ApplicationRecord
    has_many :user_genres
    has_many :users, through: :user_genres
    has_many :books

    def self.available_genres
        Genre.all.pluck(:name)
    end

    def self.get_misc
        Genre.find_by(name: "misc")
    end
end
