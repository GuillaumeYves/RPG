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
      get 'leaderboard'
      get 'thaumaturge'
    end
    member do
      get '/combat_result/:id', to: 'combat#combat_result', as: :combat_result
      post 'select', to: 'characters#select'
      get 'talents'
      post 'gain_experience'
      post 'learn_skill'
      post 'unlearn_skill'
      post 'complete_hunt'
      post 'add_to_inventory/:item_id', to: 'characters#add_to_inventory', as: :add_to_inventory
      delete 'remove_from_inventory/:item_id', to: 'characters#remove_from_inventory', as: :remove_from_inventory
      post '/combat', to: 'combat#combat', as: :combat
      post 'equip_item/:item_id', to: 'characters#equip_item', as: :equip_item
      post 'sell_item/:item_id', to: 'characters#sell_item', as: :sell_item
      post 'use_elixir/:item_id', to: 'characters#use_elixir', as: :use_elixir
      post 'equip_prompt'
      post 'spend_skill_point'
      post 'heal'
      post 'paragon_increase_attack'
      post 'paragon_increase_armor'
      post 'paragon_increase_spellpower'
      post 'paragon_increase_magic_resistance'
      post 'paragon_increase_critical_strike_chance'
      post 'paragon_increase_critical_strike_damage'
      post 'paragon_increase_total_health'
      post 'paragon_increase_global_damage'
      post 'paragon_reset_attack'
      post 'paragon_reset_armor'
      post 'paragon_reset_spellpower'
      post 'paragon_reset_magic_resistance'
      post 'paragon_reset_critical_strike_chance'
      post 'paragon_reset_critical_strike_damage'
      post 'paragon_reset_total_health'
      post 'paragon_reset_global_damage'
      patch 'select_hunt'
    end
  end

  resources :items

  resources :hunts, only: [:index] do
    member do
      post '/combat', to: 'combat#combat', as: :combat
      post 'accept_hunt', to: 'hunts#accept_hunt'
      post 'cancel_hunt', to: 'hunts#cancel_hunt'
    end
  end

  resources :quests, only: [:index] do
    member do
      post 'accept', to: 'quests#accept_quest'
      post 'cancel', to: 'quests#cancel_quest'
    end
  end

  get '/user_characters', to: 'characters#user_characters', as: 'user_characters'
  get '/combat_result', to: 'combat#combat_result', as: :combat_result
  post 'reset_merchant_items', to: 'items#reset_merchant_items', as: :reset_merchant_items
end
