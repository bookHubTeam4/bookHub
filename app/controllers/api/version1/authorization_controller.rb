require 'httparty'                                                             
require 'json'  

class Api::Version1::AuthorizationController < ApplicationController
    include HTTParty

    def get_authorization
      url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params['id_token']}"                  
      response = HTTParty.get(url)   
      data = response.parsed_response
      user_present = User.exists?(email: data['email'])
      if user_present
        render json: {message: 'User already registered'}
      else
        @user = User.create_user_for_google(response.parsed_response) 
        @user.password = @user.authentication_token     
        @user.save
        render json: @user, status: status
      end
    end
    
end