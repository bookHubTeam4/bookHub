class User < ApplicationRecord
    acts_as_token_authenticatable
    # field :authentication_token
    
    has_and_belongs_to_many :books
    has_many :comments
    has_many :ratings

    # Validations ...
    validates :email, presence: true
    validates :password, presence: true

    def valid_password?(pass)
        pass.eql? password
   end
end
