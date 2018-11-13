class Api::Version1::GenresController < ApplicationController

  def index
    genres = Genre.available_genres
    render json: {genres: genres}
  end

  def add_user_favourite_genres
    user = User.find_by_authentication_token(params[:auth_token])
    if user.blank?
      render json: {
        message: "Cannot find user",
      }
    else
      Rails.logger.info("......params[:genres] - #{params[:genres]}")
      genres = JSON.parse(params[:genres])
      Rails.logger.info("......Json.parse response - #{genres}")
      user.add_genre(genres)
      render json: {
        message: "Successfully added favourite genres.",
        user: user.full_data
      }
    end

  end

 
end
