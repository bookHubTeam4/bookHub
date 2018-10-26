class UserBook < ApplicationRecord
    belongs_to :user
    belongs_to :book
    enum status: [:reading, :wants_to_read, :read]
    
 end
