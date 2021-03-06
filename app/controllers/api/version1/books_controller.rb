module Api
    module Version1

class BooksController < ApplicationController

    def search_book
        @search = params[:search]
        @books = []
    # @users = User.find_user(:search)
    if params[:search]
     
      Rails.logger.info(params[:search])
      google_key = Figaro.env.google_key

      goog_response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=#{params[:search]}&key=AIzaSyAdmqeDjVc3Nmb6GvAgTIh1AOwE0ZrvpXE")
      Rails.logger.info(".................................................#{goog_response}")
      @google_items = goog_response.parsed_response['items']

      if @google_items
        @google_items[0..19].each do |result|
          if result['volumeInfo']['imageLinks']
            book_img = result['volumeInfo']['imageLinks']['thumbnail']
          else
            next
          end

          identifiers = result['volumeInfo']['industryIdentifiers']
          isbn = nil

          if identifiers
            identifiers.each do |identifier|
              if identifier.has_value?('ISBN_10')
                isbn = identifier['identifier']
              elsif identifier.has_value?('OTHER')
                isbn = nil
              end
            end
          end

          next if isbn == nil

          authors = result['volumeInfo']['authors']
          if authors
            authors_string = authors.join(', ')
          end
          Rails.logger.info(@books)
          @books << { title: result['volumeInfo']['title'], author: authors_string, description: result['volumeInfo']['description'], isbn: isbn, book_image: book_img }
        end
      end
      
    
    end

    render json: {books: @books, status: 'success'}
    
    end

    def show_book
        @isbn = params[:name]
        #book_data = {}
            Rails.logger.info(params[:name])          
            book = Book.api_call(@isbn)
            book_volume_info = book['volumeInfo']
            authors = book_volume_info['authors'] if book
            Rails.logger.info(book_volume_info['authors'])
            authors_string = authors.join(', ') if authors
            google_id = book['id']
            book_status = nil
            #check if the book exist else book has not been data base
            if Book.book_selector(@isbn)
              Rails.logger.info(".................................................#{Book.book_selector(@isbn)}")
              user = User.get_user(params[:token])
              #check if the user exists
              if user 
                #check if the book is in the user books list
                Rails.logger.info(".................................................#{user.books}")
                if user.books.include?(Book.book_selector(@isbn))
                  
                  book_status = user.user_books.find_by(book_id: Book.book_selector(@isbn).id).status
                  Rails.logger.info(".................................................#{book_status}")
                end
              
              end
            
            end
            book_data = { title: book_volume_info['title'],
                          isbn: @isbn,
                          author: authors_string,
                          description: book_volume_info['description'],
                          image_url: book_volume_info['imageLinks']['thumbnail'],
                          genre_id: 20,
                          google_id: google_id,
                          page_count: book_volume_info['pageCount'],
                          average_rating: book_volume_info['averageRating'],
                          published_date: book_volume_info['publishedDate'],
                          publisher: book_volume_info['publisher'] ,
                          book_status: book_status
                        }

        render json: {book: book_data, status: 'success'}

    end

    def book_list
      @books = {}
      if User.present?(params[:authentication_token])
        user = User.get_user(params[:authentication_token])
        @genreList = user.genres
        Rails.logger.info(".................................................#{@genreList[0].inspect}")
        if @genreList.any?
          @genreList.each do |genere|
            @books[genere.name] = genere.books.limit(10)
            Rails.logger.info("///////////////////////////////////////////////////////#{genere.books}") 
          end
        
        end
          @books_top        = Book.where('ny_times_list = ?', 'Mass Market Paperback')
          @books_travel     = Book.where('ny_times_list = ?', 'Travel')
          Rails.logger.info("///////////////////////////////////////////////////////#{@books_travel}") 
          @books_science    = Book.where('ny_times_list = ?', 'Science')
          @books_business   = Book.where('ny_times_list = ?', 'Business Books')
          @books_animals    = Book.where('ny_times_list = ?', 'Animals')
          @books_education  = Book.where('ny_times_list = ?', 'Education')
          @books_nonfiction = Book.where('ny_times_list = ?', 'Hardcover Nonfiction')
          @book_ny = { 'Top Selling' => @books_top, 'Nonfiction' => @books_nonfiction, 'travel' => @books_travel, 'science' => @books_science, 'Business' => @books_business, 'Animals' => @books_animals, 'Education' => @books_education }
          @books.merge!(@book_ny)
        
      end
      render json: {book: @books, status: 'success'}
    end

end
end
end
