Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    resources :locations, only: [:index, :show] do
      resource :weather, only: [:show]
    end

    # destroy takes a location id rather than a UserFavorite id; see
    # Api::UserFavoritesController#destroy.
    resources :user_favorites, only: [:index, :create, :destroy]
  end
end
