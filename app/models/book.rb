class Book < ApplicationRecord
    has_many :user_books
    has_many :users, through: :user_books
    has_many :comments
    has_many :ratings

    def self.api_call(isbn)      
        google_key = Figaro.env.google_key
        book_response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=isbn=#{isbn}&key=#{google_key}")
        book = book_response.parsed_response['items'][0]
        return book if book_response
    end

    def self.required_info(isbn)
        book = Book.api_call(isbn)
        book_volume_info = book['volumeInfo']
            authors = book_volume_info['authors'] if book
            authors_string = authors.join(', ') if authors
         { description: book_volume_info['description'],
          bName: book_volume_info['title'],
          isbn: isbn,
          bAuthor: authors_string }
    end

    def self.add_new_book(book)
        self.create(book)
    end
end
