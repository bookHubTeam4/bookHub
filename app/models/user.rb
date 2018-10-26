class User < ApplicationRecord
    acts_as_token_authenticatable

    # Assosiations ...
    has_many :user_books
    has_many :books, through: :user_books
    has_many :comments
    has_many :ratings

    # Validations ...
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true
    validates :firstName, presence: true
    validates :lastName, presence: true

    # methods ...
    def valid_password?(pass)
        pass.eql? password
   end
end
