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
    
    @response_education = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=education")
    @response_nonfiction = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=hardcover-nonfiction")
    @response_nonfiction = HTTParty.get("https://api.nytimes.com/svc/books/v3/lists.json?api-key=#{nytimes_key}&list=sports")

    @items = []
    Rails.logger.info(".................................................#{@response}")
    @items << @response.parsed_response['results']
    @items << @response_travel.parsed_response['results']
    @items << @response_science.parsed_response['results']
    @items << @response_business.parsed_response['results']
    @items << @response_animals.parsed_response['results']
    @items << @response_education.parsed_response['results']
    @items << @response_nonfiction.parsed_response['results']
    puts 'Starting'
    Rails.logger.info(".................................................#{@items}")
    @items.each do |item|
      @item = item
      item.each do |result|
        @result = result
        @isbn = result['book_details'][0]['primary_isbn10']
        @list = result['list_name']
      
        if @isbn
          @book = Book.book_selector(@isbn)
          if !@book
          @book = Book.new_book_data(@isbn)
          bb = Book.new(@book)
          bb.ny_times_list = @list
          else
             bb = @book
             bb.ny_times_list = @list
          end
        else
          next
        end
       
        bb.save
        puts bb.bName + ' found or created.'
      end
    end
  end

  desc 'Update Google API for recommendations'
  task :google_rec do
    puts 'Updating genre recommendations from Google Books API'
    genres = Genre.all

    genres.each do |genre|
      Rails.logger.info(".................................................#{genre}")
      name = genre.name
      id = genre.id
      google_key = Figaro.env.google_key
      response = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=subject=#{name}&key=#{google_key}")
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
          Rails.logger.info(".................................................#{Book.exists?(isbn)}")
          if Book.exists?(isbn)
            Rails.logger.info(".................................................#{isbn}")
          else
            Rails.logger.info("........................................................................................#{item}...")
           
            info = item["volumeInfo"]
            Rails.logger.info("#####################################################################..............................................#{info}...")

            Rails.logger.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!..............................................#{item["volumeInfo"]["authors"]}...")
            #authors = item["volumeInfo"]["authors"]

            # Rails.logger.info(".....................................
            #   #{info['title']}..........................#{info['imageLinks']['thumbnail']}.............#{info['description']}................#{info}")
           
            # google_id = response.parsed_response['items'][item]['id']
            if info.key?('description')
            description = info['description']
            else
            description = nil
            end

            if info.key?('imageLinks')
              if info['imageLinks'].key?('thumbnail')
                image = info['imageLinks']['thumbnail']
              end
            else
              image = "https://s3.ca-central-1.amazonaws.com/bucket4sree/no-cover-placeholder+(1).jpg"
            end
            book = Book.create(isbn: isbn,
                               bName: item["volumeInfo"]["title"],
                               bAuthor: item["volumeInfo"]["authors"],
                               description: description,
                               image_url: image,
                               genre_id: id
                               )
            puts book.bName + ' created.'
          end
        end
      end
    end
  end
end
