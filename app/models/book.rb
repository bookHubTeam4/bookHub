class Book < ApplicationRecord
    has_many :user_books
    has_many :users, through: :user_books
    has_many :comments
    has_many :ratings

    def self.book_selector(isbn)
        book = Book.find_by(isbn: isbn)
        return book if book
      end
    
    def self.api_call(isbn)
        
        google_key = Figaro.env.google_key
        book_response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=isbn=#{isbn}&key=#{google_key}")
        book = book_response.parsed_response['items'][0]
        return book if book_response
      end

    def self.find_or_api_call(isbn)
        book = Book.book_selector(isbn)
        return book if !book.nil?
        book = Book.new_book_data(isbn) if book.nil?
        return book if !book.nil?
        if book.nil?
          return 'Book not found'
        end
    end

    def self.exists?(isbn)
        book = Book.find_by(isbn: isbn)
        if book
          return book
        end
    end

    def self.new_book_data(isbn)
        book = Book.api_call(isbn)
        book_volume_info = book['volumeInfo']
        authors = book['authors'] if book
        authors_string = authors.join(', ') if authors
        google_id = book['id']
        book_data = {title: book_volume_info['title'],
                    isbn: isbn,
                    author: authors_string,
                    description: book_volume_info['description'],
                    image_url: book_volume_info['imageLinks']['thumbnail'],
                    genre_id: 20,
                    google_id: google_id,
                    page_count: book_volume_info['pageCount'],
                    average_rating: book_volume_info['averageRating'],
                    published_date: book_volume_info['publishedDate'],
                    publisher: book_volume_info['publisher'] }
        return book_data
    end
end
