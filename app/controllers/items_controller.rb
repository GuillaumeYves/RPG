class ItemsController < ApplicationController
before_action :authenticate_user!

    def index
        @character = current_user.selected_character

        @random_weapon_items = Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"], merchant_item: true)
        @random_armor_items = Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"], merchant_item: true)
        @random_jewelry_items = Item.where(item_type: ["Finger", "Neck"], merchant_item: true)
    end

    def reset_merchant_items
        @character = current_user.selected_character
        Item.reset_items
        Item.set_merchant_items

        @character.gold -= 10
        @character.save
        flash[:notice] = "Stocks renewed"
        redirect_to items_path
    end

end
