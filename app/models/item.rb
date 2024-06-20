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

    def randomize_rarity
        self.rarity ||= rand < 0.8 ? "Common" : "Rare"
    end

    def randomize_attributes
        randomize_rarity
        min_attribute_value = 1
        attributes = [:strength, :intelligence, :dreadmight, :agility, :luck, :willpower]
        allocated_attributes = {}
        case self.rarity
            when "Rare"
                total_attributes_to_allocate = 400
                2.times do
                    break if total_attributes_to_allocate <= 0
                    attribute = attributes.sample
                    allocated_value = rand(min_attribute_value..total_attributes_to_allocate)
                    total_attributes_to_allocate -= allocated_value
                    allocated_attributes[attribute] ||= 0
                    allocated_attributes[attribute] += allocated_value
                end
            when "Common"
                total_attributes_to_allocate = 300
                1.times do
                    break if total_attributes_to_allocate <= 0
                    attribute = attributes.sample
                    allocated_value = rand(min_attribute_value..total_attributes_to_allocate)
                    total_attributes_to_allocate -= allocated_value
                    allocated_attributes[attribute] ||= 0
                    allocated_attributes[attribute] += allocated_value
                end
        end
        # Assign attributes to the item
        allocated_attributes.each do |attribute, value|
            self.send("#{attribute}=", value)
        end
        # Update the item name based on the attributes
        update_item_name unless ["Epic", "Legendary"].include?(self.rarity)
    end

    def update_item_name
        suffixes = {
            strength: "of Strength",
            intelligence: "of Intelligence",
            dreadmight: "of Dreadmight",
            luck: "of Luck",
            agility: "of Agility",
            willpower: "of Willpower"
        }
        prefixes = {
            strength: "Strong",
            intelligence: "Intelligent",
            dreadmight: "Dreadful",
            luck: "Lucky",
            agility: "Agile",
            willpower: "Resolute"
        }
        new_name = self.name
        allocated_attributes = {
            strength: self.strength,
            intelligence: self.intelligence,
            dreadmight: self.dreadmight,
            luck: self.luck,
            agility: self.agility,
            willpower: self.willpower
        }.compact
        # Collect attributes
        attribute_names = allocated_attributes.keys
        if attribute_names.length == 1
            # If there is only one attribute, use a prefix
            attribute = attribute_names.first
            new_name = "#{prefixes[attribute]} #{new_name}"
        elsif attribute_names.length >= 2
            # If there are two or more attributes, use a prefix and a suffix
            first_attribute = attribute_names[0]
            second_attribute = attribute_names[1]
            prefix_name = prefixes[first_attribute]
            suffix_name = suffixes[second_attribute]
            new_name = "#{prefix_name} #{new_name} #{suffix_name}"
        end
        self.name = new_name
    end

    def dupe_item
        duped_item = self.dup
        duped_item.min_attack = (self.min_attack * (rand(0.8..1.0))).to_i if self.min_attack.present?
        duped_item.max_attack = (self.max_attack * (rand(0.8..1.0))).to_i if self.max_attack.present?
        duped_item.min_spellpower = (self.min_spellpower * (rand(0.8..1.0))).to_i if self.min_spellpower.present?
        duped_item.max_spellpower = (self.max_spellpower * (rand(0.8..1.0))).to_i if self.max_spellpower.present?
        duped_item.min_necrosurge = (self.min_necrosurge * (rand(0.8..1.0))).to_i if self.min_necrosurge.present?
        duped_item.max_necrosurge = (self.max_necrosurge * (rand(0.8..1.0))).to_i if self.max_necrosurge.present?
        duped_item.health = (self.health * (rand(0.8..1.0))).to_i if self.health.present?
        duped_item.armor = (self.armor * (rand(0.8..1.0))).to_i if self.armor.present?
        duped_item.magic_resistance = (self.magic_resistance * (rand(0.8..1.0))).to_i if self.magic_resistance.present?
        duped_item.global_damage = (self.global_damage * (rand(0.8..1.0))) if self.global_damage.present?
        duped_item.critical_strike_chance = (self.critical_strike_chance * (rand(0.8..1.0))) if self.critical_strike_chance.present?
        duped_item.critical_strike_damage = (self.critical_strike_damage * (rand(0.8..1.0))) if self.critical_strike_damage.present?
        if self.rarity == "Epic" || self.rarity == "Legendary"
            duped_item.strength = (self.strength * (rand(0.8..1.0))).to_i if self.strength.present?
            duped_item.intelligence = (self.intelligence * (rand(0.8..1.0))).to_i if self.intelligence.present?
            duped_item.agility = (self.agility * (rand(0.8..1.0))).to_i if self.agility.present?
            duped_item.dreadmight = (self.dreadmight * (rand(0.8..1.0))).to_i if self.dreadmight.present?
            duped_item.luck = (self.luck * (rand(0.8..1.0))).to_i if self.luck.present?
            duped_item.willpower = (self.willpower * (rand(0.8..1.0))).to_i if self.willpower.present?
        else
            duped_item.randomize_attributes
        end
        duped_item.generated_item = true
        attach_image_to_item(duped_item, self.item_image.blob.key)
        duped_item.save
        duped_item
    end

    def self.dupe_and_set_merchant_item(item)
        duped_item = item.dupe_item
        duped_item.merchant_item = true
        duped_item.save
    end

    def self.set_merchant_items
        Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"], merchant_item: false, generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }

        Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"], merchant_item: false, generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }

        Item.where(item_type: ["Finger", "Neck"], merchant_item: false, generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }
    end

    def self.reset_items
        where(merchant_item: true, generated_item: true).each do |item|
            item.destroy
        end
    end

end
