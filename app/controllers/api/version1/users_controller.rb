
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
          render json: {message: "Updated Shelf Successfully.."}
        else
          render json: {message: "Not enough Information.. "}
        end
     end

    private 
    def user_params
        params.permit(:firstName, :lastName, :email, :password, :provider)
    end
end
