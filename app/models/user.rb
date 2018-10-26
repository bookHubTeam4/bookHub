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

   def self.create_user_for_google(data)
      user = User.new
      user.provider = 'Google'
      user.firstName = data['given_name']
      user.lastName = data['family_name']
      user.uid = data['email']
      user.email = data['email']
      user.password = 'password'
      user.save!
      return user
    end


    # whether user present or not
    def self.present?(token)
      User.exists?(authentication_token: token)
    end

    def self.get_user(token)
      User.where(authentication_token: token).first if User.present?(token)
    end

end
