class ItemsController < ApplicationController
before_action :authenticate_user!

    def index
        @selected_character = Character.find(session[:selected_character_id])
        @items = Item.all
        
        @random_weapon_items = Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon"]).order("RANDOM()").limit(5)
        @random_armor_items = Item.where(item_type: ["Shield", "Helmet", "Chest"]).order("RANDOM()").limit(5)
        @random_jewelry_items = Item.where(item_type: ["Ring", "Amulet"]).order("RANDOM()").limit(5)
    end

end