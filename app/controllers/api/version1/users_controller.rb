
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

    private 
    def user_params
        params.permit(:firstName, :lastName, :email, :password, :provider)
    end
end
