Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    resources :locations, only: [:index, :show, :create] do
      resource :weather, only: [:show]
    end
    resources :location_candidates, only: [:index]

    # destroy takes a location id rather than a UserFavorite id; see
    # Api::UserFavoritesController#destroy.
    resources :user_favorites, only: [:index, :create, :destroy]
    resource :current_user, only: [:show]

    namespace :admin do
      resources :location_favorite_counts, only: [:index]
    end
  end
end
