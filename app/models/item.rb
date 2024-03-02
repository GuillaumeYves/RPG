class Item < ApplicationRecord
    belongs_to :character, optional: true
    belongs_to :inventory, optional: true, polymorphic: true

    has_one_attached :item_image

    def self.set_merchant_items
        Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"], merchant_item: false)
            .order('RANDOM()')
            .limit(5)
            .update_all(merchant_item: true)
        Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"], merchant_item: false)
            .order('RANDOM()')
            .limit(5)
            .update_all(merchant_item: true)
        Item.where(item_type: ["Finger", "Neck"], merchant_item: false)
            .order('RANDOM()')
            .limit(5)
            .update_all(merchant_item: true)
    end

    def self.reset_items
        where(purchased: true).update_all(purchased: false)
        where(merchant_item: true).update_all(merchant_item: false)
    end

end
