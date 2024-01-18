Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "characters#user_characters"

  resources :characters do
    collection do
      get 'user_characters'
      get 'leaderboard'
    end
    member do
      get '/combat_result/:id', to: 'combat#combat_result', as: :combat_result
      post 'select', to: 'characters#select'
      post 'gain_experience'
      post 'unlock_skill'
      post 'complete_hunt'
      post 'add_to_inventory/:item_id', to: 'characters#add_to_inventory', as: :add_to_inventory
      delete 'remove_from_inventory/:item_id', to: 'characters#remove_from_inventory', as: :remove_from_inventory
      post 'equip_item/:item_id', to: 'characters#equip_item', as: :equip_item
      post 'equip_prompt'
      post 'spend_skill_point'
      patch 'select_hunt'
    end
  end

  resources :items

  resources :hunts, only: [:index] do
    member do
      get '/combat_hunt', to: 'combat#combat', as: :combat_hunt
      post 'accept_hunt', to: 'hunts#accept_hunt'
      post 'cancel_hunt', to: 'hunts#cancel_hunt'
    end
  end

  get '/user_characters', to: 'characters#user_characters', as: 'user_characters'
  get '/combat_result', to: 'combat#combat_result', as: :combat_result
  get 'update_health_bars', to: 'combat_controller#update_health_bars'

end

