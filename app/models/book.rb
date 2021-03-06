class Book < ApplicationRecord
    has_many :user_books
    has_many :users, through: :user_books
    has_many :comments
    has_many :ratings
    belongs_to :genre


    def self.book_selector(isbn)
        book = Book.find_by(isbn: isbn)
        return book if book
      end
    
    def self.api_call(isbn)
        google_key = Figaro.env.google_key
        book_response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=isbn=#{isbn}&key=#{google_key}")
        book = book_response.parsed_response['items'][0]

        Rails.logger.info(".................................................#{book}")
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
        else
          return false
        end
    end

    def self.new_book_data(isbn)
        book = Book.api_call(isbn)
        book_volume_info = book['volumeInfo']
        authors = book['authors'] if book
        #authors_string = authors.join(', ') if authors
        google_id = book['id']
        book_data = {bName: book_volume_info['title'],
                    isbn: isbn,
                    bAuthor: authors,
                    description: book_volume_info['description'],
                    image_url: book_volume_info['imageLinks']['thumbnail'],
                    genre_id: 20,
                   #google_id: google_id,
                    ny_times_list: '',
                    #page_count: book_volume_info['pageCount'],
                    #average_rating: book_volume_info['averageRating'],
                    #published_date: book_volume_info['publishedDate'],
                    #publisher: book_volume_info['publisher']
                 }


                    puts ".......................#{book_data}"
        return book_data
    end

    def self.required_info(isbn)
        book = Book.api_call(isbn)
        # binding.pry
        book_volume_info = book['volumeInfo']
        authors = book_volume_info['authors'] if book
        authors_string = authors.join(', ') if authors
        book_data = {description: book_volume_info['description'],
                     bName: book_volume_info['title'],
                     isbn: isbn,
                     bAuthor: authors_string}
          return book_data
    end

    def self.create_or_return_book(book)
        Book.where(book).first_or_initialize
    end

    def self.get_book_image(isbn)
        book = Book.api_call(isbn)

        book_volume_info = book['volumeInfo']
        Rails.logger.info(".................................................#{book['volumeInfo']}")
        book_volume_info['imageLinks']['thumbnail']
    end


    def self.get_author(isbn)
        book = Book.api_call(isbn)
        Rails.logger.info(".................................................#{book['volumeInfo']}")
        authors = book['volumeInfo']['authors'] if book
    end
    
end
