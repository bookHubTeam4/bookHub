Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'version1' do
      resources :books, only: [:index, :show],  param: :name
      resources :users, only: [:create]
      resources :sessions, only: [:create]
      resources :genres, only: [:index]
      post 'genre/add_user_genres', to:'genres#add_user_favourite_genres'
      post 'user/save_book', to: 'users#add_to_shelf'
      delete 'sessions/sign_out'
     

     post 'book/search' => 'books#search_book', param: :search
     post 'book/recomendation' => 'books#book_list'
    #  post 'auth/request', to:'authorization#get_authorization'
     post 'auth/request', to: 'users#oauth_signup'
    end
  end
  
end
