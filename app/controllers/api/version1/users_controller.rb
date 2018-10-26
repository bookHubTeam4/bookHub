
class Api::Version1::UsersController < ApplicationController

    def create
       @user = User.new(user_params)
       @user.uid = params[:email]
       if @user.save
         render json: @user, status: status
       else
        render json: {errors: @user.errors.full_messages}
       end
    end

    private 
    def user_params
        params.permit(:firstName, :lastName, :address, :email, :password)
    end
end
