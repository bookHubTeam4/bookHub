class UserBook < ApplicationRecord
    belongs_to :user
    belongs_to :book
    enum status: {wants_to_read: 1, reading: 2, read: 3}
 
 end
