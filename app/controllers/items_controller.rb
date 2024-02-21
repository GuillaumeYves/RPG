class ItemsController < ApplicationController
before_action :authenticate_user!

    def index
        @selected_character = current_user.selected_character
        @items = Item.all

        @random_weapon_items = Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"]).order("RANDOM()").limit(5)
        @random_armor_items = Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"]).order("RANDOM()").limit(5)
        @random_jewelry_items = Item.where(item_type: ["Finger", "Neck"]).order("RANDOM()").limit(5)
    end

end
