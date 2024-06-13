class ItemsController < ApplicationController
before_action :authenticate_user!

    def index
        @selected_character = current_user.selected_character

        @random_weapon_items = Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"], merchant_item: true, purchased: false)
        @random_armor_items = Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"], merchant_item: true, purchased: false)
        @random_jewelry_items = Item.where(item_type: ["Finger", "Neck"], merchant_item: true, purchased: false)
    end

    def reset_merchant_items
        @character = current_user.selected_character
        Item.reset_items
        Item.set_merchant_items

        @character.gold -= 10
        @character.save

        respond_to do |format|
            format.js { render js: "window.location.reload()" }
        end
    end

end
