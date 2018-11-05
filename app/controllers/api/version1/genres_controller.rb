class Api::Version1::GenresController < ApplicationController

  def index
    genres = Genre.all.pluck(:name)
    render json: genres
  end

  def add_user_favourite_genres
    user = User.find_by_authentication_token(params[:auth_token])
    if user.blank?
      render json: {
        message: "Cannot find user",
      }
    else
      genres = JSON.parse(params[:genres])
      user.add_genre(genres)
      render status: 200, json: {
        message: "Successfully added favourite genres.",
        favourite_genres: user.genres.pluck(:name)
      }
    end

  end

 
end
