
class Api::Version1::UsersController < ApplicationController

    def create
       @user = User.new(user_params)
       if @user.save
         render json: @user, status: status
       else
        head(:unprocessable_entity)
       end
    end

    private 
    def user_params
        params.permit(:firstName, :lastName, :address, :email, :password)
    end
end
