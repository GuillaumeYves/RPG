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

    def attach_image_to_item(item, image_key)
        item.item_image.attach(io: StringIO.new(ActiveStorage::Blob.service.download(image_key)), filename: self.item_image.filename.to_s, content_type: self.item_image.content_type)
    end

    def dupe_item
        duped_item = self.dup
        duped_item.min_attack = (self.min_attack * (rand(0.8..1.0))).to_i if self.min_attack.present?
        duped_item.max_attack = (self.max_attack * (rand(0.8..1.0))).to_i if self.max_attack.present?
        duped_item.min_spellpower = (self.min_spellpower * (rand(0.8..1.0))).to_i if self.min_spellpower.present?
        duped_item.max_spellpower = (self.max_spellpower * (rand(0.8..1.0))).to_i if self.max_spellpower.present?
        duped_item.min_necrosurge = (self.min_necrosurge * (rand(0.8..1.0))).to_i if self.min_necrosurge.present?
        duped_item.max_necrosurge = (self.max_necrosurge * (rand(0.8..1.0))).to_i if self.max_necrosurge.present?
        duped_item.strength = (self.strength * (rand(0.8..1.0))).to_i if self.strength.present?
        duped_item.luck = (self.luck * (rand(0.8..1.0))).to_i if self.luck.present?
        duped_item.willpower = (self.willpower * (rand(0.8..1.0))).to_i if self.willpower.present?
        duped_item.health = (self.health * (rand(0.8..1.0))).to_i if self.health.present?
        duped_item.armor = (self.armor * (rand(0.8..1.0))).to_i if self.armor.present?
        duped_item.magic_resistance = (self.magic_resistance * (rand(0.8..1.0))).to_i if self.magic_resistance.present?
        duped_item.intelligence = (self.intelligence * (rand(0.8..1.0))).to_i if self.intelligence.present?
        duped_item.agility = (self.agility * (rand(0.8..1.0))).to_i if self.agility.present?
        duped_item.dreadmight = (self.dreadmight * (rand(0.8..1.0))).to_i if self.dreadmight.present?
        duped_item.global_damage = (self.global_damage * (rand(0.8..1.0))).round(2) if self.global_damage.present?
        duped_item.critical_strike_chance = (self.critical_strike_chance * (rand(0.8..1.0))).round(2) if self.critical_strike_chance.present?
        duped_item.critical_strike_damage = (self.critical_strike_damage * (rand(0.8..1.0))).round(2) if self.critical_strike_damage.present?
        duped_item.generated_item = true
        attach_image_to_item(duped_item, self.item_image.blob.key)
        duped_item.save
        duped_item
    end

    def self.set_merchant_items
        Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"], merchant_item: false,  generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }

        Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"], merchant_item: false,  generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }

        Item.where(item_type: ["Finger", "Neck"], merchant_item: false,  generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }
    end

    def self.dupe_and_set_merchant_item(item)
        duped_item = item.dupe_item
        duped_item.merchant_item = true
        duped_item.save
    end

    def self.reset_items
        where(merchant_item: true, generated_item: true).each do |item|
            item.destroy
        end
    end

end
