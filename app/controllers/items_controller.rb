class ItemsController < ApplicationController
before_action :authenticate_user!

    def index
        @selected_character = Character.find(session[:selected_character_id])
        @items = Item.all
        
        @random_weapon_items = Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon"]).order("RANDOM()").limit(3)
        @random_armor_items = Item.where(item_type: ["Shield", "Head", "Chest", "Feet", "Waist", "Hands", "Legs"]).order("RANDOM()").limit(3)
        @random_jewelry_items = Item.where(item_type: ["Finger", "Neck"]).order("RANDOM()").limit(3)
    end

end