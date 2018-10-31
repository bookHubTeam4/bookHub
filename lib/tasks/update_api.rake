# Load Rails
# ENV['RAILS_ENV'] = ARGV[0] || 'production'
require File.dirname(__FILE__) + '/../../config/environment'

namespace :update_api do
  desc 'Update NY Times API'
  task :ny_times do
    puts 'Updating NY Times List book data...'

    nytimes_key = Figaro.env.nytimes_key
    @response = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=mass-market-paperback")
    @response_travel = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=travel")
    @response_science = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=science")
    @response_business = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=business-books")
    @response_animals = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=animals")
    sleep 1
    @response_education = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=education")
    @response_nonfiction = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=hardcover-nonfiction")
    @response_nonfiction = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=sports")

    @items = []
    @items << @response.parsed_response['results']
    @items << @response_travel.parsed_response['results']
    @items << @response_science.parsed_response['results']
    @items << @response_business.parsed_response['results']
    @items << @response_animals.parsed_response['results']
    @items << @response_education.parsed_response['results']
    @items << @response_nonfiction.parsed_response['results']
    puts 'Starting'

    @items.each do |item|
      @item = item
      item.each do |result|
        @result = result
        @isbn = result['book_details'][0]['primary_isbn10']
        @list = result['list_name']
        if @isbn
          @book = Book.find_or_api_call(@isbn)
        else
          next
        end
        @book.ny_times_list = @list
        @book.save
        puts @book.title + ' found or created.'
      end
    end
  end

  desc 'Update Google API for recommendations'
  task :google_rec do
    puts 'Updating genre recommendations from Google Books API'
    genres = Genre.all

    genres.each do |genre|
      name = genre.name
      id = genre.id
      response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=subject=#{name}&key=#{ENV['GBOOKS_KEY']}")
      items = response.parsed_response['items']

      items.each do |item|
        identifiers = item['volumeInfo']['industryIdentifiers']
        isbn = nil

        if identifiers
          identifiers.each do |identifier|
            if identifier.has_value?('ISBN_10')
              isbn = identifier['identifier']
            end
          end
        end

        if isbn == nil
          next
        else
          if Book.exists?(isbn)
            next
          else
            info = item['volumeInfo']
            authors = info['authors']
           
            # google_id = response.parsed_response['items'][item]['id']
            book = Book.create(isbn: isbn,
                               bName: info['title'],
                               bAuthor: authors,
                               description: info['description'],
                               image_url: info['imageLinks']['thumbnail'],
                               genre_id: id
                               )
            puts book.title + ' created.'
          end
        end
      end
    end
  end
end
