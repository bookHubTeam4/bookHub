class Book < ApplicationRecord
    has_many :users
    has_many :comments
    has_many :ratings

    def self.api_call(isbn)
        
        google_key = Figaro.env.google_key
        book_response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=isbn=#{isbn}&key=#{google_key}")
        book = book_response.parsed_response['items'][0]
        return book if book_response
      end
end
