Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'version1' do
      resources :books, only: [:index, :show],  param: :name
      resources :users, only: [:create]
      resources :sessions, only: [:create]
      delete 'sessions/sign_out'
     

     post 'book/search' => 'books#search_book', param: :search
     post 'auth/request', to:'authorization#get_authorization'
    end
  end
  
end
