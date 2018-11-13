class UserBook < ApplicationRecord
    belongs_to :user
    belongs_to :book
    enum status: {wants_to_read: 1, reading: 2, read: 3}

    def self.from_shelf(user_id, book_id)
        UserBook.find_by(user_id: user_id, book_id: book_id)
    end

    def self.present?(user_id, book_id)
        UserBook.exists?(user_id: user_id, book_id: book_id)
    end
 
 end
