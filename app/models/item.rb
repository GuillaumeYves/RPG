class Item < ApplicationRecord
    belongs_to :character, optional: true
    belongs_to :inventory, optional: true, polymorphic: true

    has_one_attached :item_image

    def upgraded_stats
        upgraded_stats = {
            health: self.upgraded_health,
            global_damage: self.upgraded_global_damage,
            critical_strike_chance: self.upgraded_critical_strike_chance,
            critical_strike_damage: self.upgraded_critical_strike_damage,
            armor: self.upgraded_armor,
            magic_resistance: self.upgraded_magic_resistance,
            strength: self.upgraded_strength,
            intelligence: self.upgraded_intelligence,
            agility: self.upgraded_agility,
            dreadmight: self.upgraded_dreadmight,
            luck: self.upgraded_luck,
            willpower: self.upgraded_willpower
        }
    end

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
