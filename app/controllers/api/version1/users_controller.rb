
class Api::Version1::UsersController < ApplicationController

    def create
       @user = User.new(user_params)
       @user.uid = params[:email]
       if @user.save
         render json: { user: @user,
                        message: "Registerd Succesfully",
                        available_genres: Genre.available_genres}
       else
        render json: {errors: @user.errors.full_messages}
       end
    end

    def oauth_signup
        user_present = User.exists?(email: params[:emailId])
        if user_present
            user = User.find_by_email(params[:emailId])
            render json: { user: user.full_data,
                           message: "Logged In Successfully"} 
        else
            user = User.oauth_register(params) 
            user.password = user.authentication_token
            if user.save
                render json: { user: user.full_data,
                               message: "Oauth Registration Succesful",
                               available_genres: Genre.available_genres}
            else
               render json: {errors: @user.errors.full_messages}
            end 
        end    
     end

     def add_to_shelf
        if params[:status] && params[:isbn] && params[:user_token]
          user = User.get_user(params[:user_token])
          Rails.logger.info("......user - #{user.id}")
          book = Book.exists?(params[:isbn])
          unless book
            book_info = Book.required_info(params[:isbn])
            book = Book.create(book_info.merge(genre_id: Genre.get_misc.id))
          end 
          Rails.logger.info("......book - #{book.id}")         
          user.books << book unless UserBook.present?(user.id, book.id)
          user_book = UserBook.find_by(user: user, book: book)
          Rails.logger.info("......user_book - #{user_book.id}")
          user_book.update(status: params[:status].to_i) if user_book
          render json: {message: "Updated Shelf Successfully.",
                        book_added: book,
                        status: user_book.status}
        else
          render json: {message: "Not enough Information.. "}
        end
     end

     def get_user_shelf
        user = User.get_user(params[:user_token])
        if user
            Rails.logger.info("......user - #{user.id}")
            shelf = {}
            user_shelf = []

            Rails.logger.info("................................book - #{user.books}")
            user.books.each do |book|
                Rails.logger.info("......book_1 - #{book.inspect}")
                
                shelf = {isbn: book.isbn, name: book.bName, author: Book.get_author(book.isbn), image_url: Book.get_book_image(book.isbn)}
                Rails.logger.info("......book_1 - #{shelf}")
                shelf[:status] = user.user_books.find_by(book_id: book.id).status
                shelf[:average_rating] = rand(2.5 .. 4.5).round(1)
                user_shelf << shelf
            end
            render json: {user_shelf: user_shelf}
        else
            render json: {message: "Please provide a valid user token!."}
        end
     end

     def update
       user = User.get_user(params[:authentication_token])
       user.update(firstName: params[:firstName],
                   lastName: params[:lastName])
         Rails.logger.info("......params[:genres] - #{params[:genres]}")
        genres = JSON.parse(params[:genres])
        Rails.logger.info("......Json.parse response - #{genres}")
       user.add_genre(genres)
       Rails.logger.info(".................................................#{user.full_data}")

       render json: { message: "User updated successfully..",
                      user: user.full_data}
     end

    private 
    def user_params
        params.permit(:firstName, :lastName, :email, :password, :provider)
    end
end
