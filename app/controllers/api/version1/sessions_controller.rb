class Api::Version1::SessionsController < ApplicationController
  def create
    user = User.where(email: params[:email]).first
    if user&.valid_password?(params[:password])
        render json: user.as_json(only: [:authentication_token]), status: :created
    else
        head(:unauthorized)
    end     
  end

  def sign_out
    render json: {authentication_token: nil}, status: status
  end

end
