class User < ApplicationRecord
    acts_as_token_authenticatable

    # Assosiations ...
    has_many :user_books
    has_many :books, through: :user_books, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :ratings, dependent: :destroy
    has_many :user_genres
    has_many :genres, through: :user_genres, dependent: :destroy

    # Validations ...
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true
    validates :firstName, presence: true
    validates :lastName, presence: true

    # methods ...
    def valid_password?(pass)
        pass.eql? password
   end

    # def self.create_user_for_google(data)                  
    #   where(uid: data['email']).first_or_initialize.tap do |user|
    #     user.provider = 'Google'
    #     user.firstName = data['given_name']
    #     user.lastName = data['family_name']
    #     user.uid = data['email']
    #     user.email = data['email']
    #     user.password = 'password' if user.password.nil?
    #     user.save!
    #   end
    # end  

    def self.oauth_register(data)                  
      where(uid: data['emailId']).first_or_initialize.tap do |user|
        user.provider = data['provider']
        user.firstName = data['firstName']
        user.lastName = data['lastName']
        user.uid = data['emailId']
        user.email = data['emailId']
        user.password = 'password' if user.password.nil?
        user.save!
      end
    end  


    # whether user present or not
    def self.present?(token)
      User.exists?(authentication_token: token)
    end

    def self.get_user(token)
      User.find_by(authentication_token: token) if User.present?(token)
    end

    def add_genre(genre_names)
      self.genres.destroy_all
      genre_names.each do |genre_name|
        genre = Genre.find_by_name(genre_name)
        self.genres << genre if genre
      end
    end

    def full_data
      user_data = self.attributes
      user_data["favourite_genres"] = self.genres.pluck(:name)
      user_data
    end
    
    # def add_book_to_shelf
    #   self.books << 
    # end

end
