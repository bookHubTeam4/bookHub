Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace 'api' do
    namespace 'version1' do
      resources :books, only: [:index, :show],  param: :name
      resources :users, only: [:create]
     post 'book/search' => 'books#search_book', param: :search
    end
  end


end
