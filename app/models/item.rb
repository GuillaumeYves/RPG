class Item < ApplicationRecord
    belongs_to :character, optional: true
    belongs_to :inventory, optional: true, polymorphic: true
    has_one_attached :item_image

    def upgraded_stats
        upgraded_stats = {
            min_attack: self.upgraded_min_attack,
            max_attack: self.upgraded_max_attack,
            min_spellpower: self.upgraded_min_spellpower,
            max_spellpower: self.upgraded_max_spellpower,
            min_necrosurge: self.upgraded_min_necrosurge,
            max_necrosurge: self.upgraded_max_necrosurge,
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

    def set_initial_stats
        self.initial_min_attack = self.min_attack if self.min_attack.present?
        self.initial_max_attack = self.max_attack if self.max_attack.present?
        self.initial_min_spellpower = self.min_spellpower if self.min_spellpower.present?
        self.initial_max_spellpower = self.max_spellpower if self.max_spellpower.present?
        self.initial_min_necrosurge = self.min_necrosurge if self.min_necrosurge.present?
        self.initial_max_necrosurge = self.max_necrosurge if self.max_necrosurge.present?
        self.initial_health = self.health if self.health.present?
        self.initial_global_damage = self.global_damage if self.global_damage.present?
        self.initial_critical_strike_chance = self.critical_strike_chance if self.critical_strike_chance.present?
        self.initial_critical_strike_damage = self.critical_strike_damage if self.critical_strike_damage.present?
        self.initial_armor = self.armor if self.armor.present?
        self.initial_magic_resistance = self.magic_resistance if self.magic_resistance.present?
        self.initial_strength = self.strength if self.strength.present?
        self.initial_intelligence = self.intelligence if self.intelligence.present?
        self.initial_agility = self.agility if self.agility.present?
        self.initial_dreadmight = self.dreadmight if self.dreadmight.present?
        self.initial_luck = self.luck if self.luck.present?
        self.initial_willpower = self.willpower if self.willpower.present?
    end

    def attach_image_to_item(item, image_key)
        item.item_image.attach(io: StringIO.new(ActiveStorage::Blob.service.download(image_key)), filename: self.item_image.filename.to_s, content_type: self.item_image.content_type)
    end

    def randomize_rarity
    self.rarity ||= begin
        roll = rand(0..100)
            if roll <= 5
                "Epic"
            elsif roll <= 20
                "Rare"
            else
                "Common"
            end
        end
    end

    def randomize_attributes
        # Define base attributes and their max values
        base_attributes = {
            luck: 100,
            willpower: 100,
        }
        # Define specific attributes for certain item types and classes
        type_class_specific_attributes = {
        "Shield_Small Shield" => { health: 1500, strength: 100, dreadmight: 100, intelligence: 100 },
        "Shield_Great Shield" => { health: 2000, strength: 100, intelligence: 100 },
        "Finger" => { critical_strike_chance: 5.0, critical_strike_damage: 0.5, health: 500, strength: 100, dreadmight: 100, agility: 100, intelligence: 100 },
        "Hands_Plate" => { critical_strike_chance: 2.5, critical_strike_damage: 0.25, health: 700, strength: 100, dreadmight: 100 },
        "Hands_Leather" => { critical_strike_chance: 2.5, critical_strike_damage: 0.25, health: 500, agility: 100 },
        "Hands_Cloth" => { critical_strike_chance: 2.5, critical_strike_damage: 0.25, health: 300, intelligence: 100 },
        "Neck" => { critical_strike_chance: 10.0, critical_strike_damage: 1.0, health: 500, strength: 100, dreadmight: 100, agility: 100, intelligence: 100 },
        "Head_Plate" => { health: 900, strength: 100, dreadmight: 100 },
        "Head_Leather" => { health: 700, agility: 100 },
        "Head_Cloth" => { health: 500, intelligence: 100 },
        "Feet_Plate" => { health: 600, strength: 100, dreadmight: 100 },
        "Feet_Leather" => { health: 400, agility: 100 },
        "Feet_Cloth" => { health: 200, intelligence: 100 },
        "Chest_Plate" => { health: 1500, strength: 100, dreadmight: 100 },
        "Chest_Leather" => { health: 1300, agility: 100 },
        "Chest_Cloth" => { health: 1100, intelligence: 100 },
        "Waist" => { health: 1000, strength: 100, dreadmight: 100, agility: 100, intelligence: 100 },
        "One-handed Weapon" => { health: 500, strength: 100, dreadmight: 100, agility: 100, intelligence: 100 },
        "Two-handed Weapon" => { health: 1000, strength: 100, dreadmight: 100, agility: 100, intelligence: 100 },
        }
        # Determine the key for specific attributes based on item type and class
        specific_key = self.item_type
        specific_key += "_#{self.item_class}" if %w[Head Hands Feet Chest Shield].include?(self.item_type)
        # Merge base attributes with specific attributes
        attributes = base_attributes.merge(type_class_specific_attributes[specific_key] || {})
        allocated_attributes = {}
        assigned_attributes = []  # Track assigned attributes
        self.randomize_rarity
        # Determine the number of attributes to assign based on rarity
        num_attributes_to_assign =
            case self.rarity
                when "Epic" then 3
                when "Rare" then 2
                when "Common" then 1
            end
        # Assign random values to attributes
        while allocated_attributes.keys.length < num_attributes_to_assign
            available_attributes = attributes.keys - assigned_attributes
            break if available_attributes.empty?
                attribute = available_attributes.sample
                max_value = attributes[attribute]
                allocated_value = max_value * rand(0.8..1.0)
                allocated_value = allocated_value.to_i unless [:critical_strike_chance, :critical_strike_damage].include?(attribute)
                allocated_attributes[attribute] ||= 0
                allocated_attributes[attribute] += allocated_value
                assigned_attributes << attribute  # Mark attribute as assigned
            end
        # Assign attributes to the item
        allocated_attributes.each do |attribute, value|
            self.send("#{attribute}=", value)
        end
        # Update the item name based on the attributes
        self.update_item_name unless self.rarity == "Legendary"
    end

    def update_item_name
        suffixes = {
            health: "of Health",
            luck: "of Luck",
            willpower: "of Resilience",
            critical_strike_chance: "of Lethality",
            critical_strike_damage: "of Ferocity",
            strength: "of Strength",
            dreadmight: "of Dreadmight",
            agility: "of Agility",
            intelligence: "of Wisdom"
        }
        prefixes = {
            health: "Healthy",
            luck: "Lucky",
            willpower: "Resilient",
            critical_strike_chance: "Lethal",
            critical_strike_damage: "Ferocious",
            strength: "Strong",
            dreadmight: "Dreadful",
            agility: "Agile",
            intelligence: "Wise"
        }
        epic_armor_names = [
            "Doomshroud",
            "Deathwhisper",
            "Stormcloak",
            "Windwraps",
            "Glimmershade",
            "Bonebreaker",
            "Hellgaze",
            "Flameveil",
            "Blizzardguard",
            "Grandguard",
            "Astreon's Gaze",
            "Lightsurge",
            "Bloodbane",
            "Earthbound",
            "Widowsilk",
            "Azurecrest",
            "Reaper's Embrace",
            "Deathclasp",
            "Executioner's Grasp",
            "Lycander's Touch",
            "Eagleeye",
            "Ondal's Eye",
            "Stormward",
            "Titan's Embrace",
            "Ghostshadow",
            "Demonclaw",
            "Blade of Sunlight",
            "Crescent Veil",
            "Doomtouch",
            "Earthshroud",
            "Famine's Grasp",
            "Hand of Divinity",
            "Mang Song's Sight",
            "Razor's Touch",
            "Blackbog's Embrace",
            "Firelizard's Gaze",
            "Stormbringer",
            "Widow's Embrace",
            "Bane's Grip",
            "Dragon's Clasp",
            "Gloomcloak",
            "Moonlight's Embrace",
            "Skullreaper",
            "Guardian's Touch",
            "Stonebreaker",
            "Hammer's Might",
            "Reaper's Hold",
            "Gravelock's Embrace",
            "Doomtouch",
            "Nightfall",
            "Shadowhusk",
            "Graveskin",
            "Nightveil",
            "Hollowheart",
            "Darkmantle",
            "Voidshroud",
            "Sorrowhide",
            "Bloodweave",
            "Deathveil",
            "Plaguewrap",
            "Grimplate",
            "Soulcage",
            "Specterhide",
            "Necroguard",
            "Shadeweave",
            "Boneveil",
            "Abyssmail",
            "Tombplate",
            "Hellshroud",
            "Gorehide",
            "Blackwrap",
            "Dreadplate",
            "Skullveil",
            "Eclipseshroud",
            "Maliceguard",
            "Ghoulhide",
            "Wraithmail",
            "Doomplate",
            "Shadowplate",
            "Phantomshroud",
            "Deathshroud",
            "Cryptwrap",
            "Soulveil",
            "Mournmail",
            "Ghastwrap",
            "Wormhide",
            "Sorrowplate",
            "Corpseguard",
            "Nightmail",
            "Spiritveil",
            "Torturehide",
            "Charnelplate",
            "Hellveil",
            "Bloodshroud",
            "Rotguard",
            "Gloomveil",
            "Baneplate",
            "Gravemail",
            "Voidveil"
        ]
        epic_weapon_names = [
            "Doombringer",
            "Death's Web",
            "Stormlash",
            "Windforce",
            "Gimmershred",
            "Boneshade",
            "Hellrack",
            "Flamebellow",
            "Buriza-Do Kyanon",
            "Grandfather",
            "Astreon's Iron Ward",
            "Lightsabre",
            "Bloodmoon",
            "Earth Shifter",
            "Widowmaker",
            "Azurewrath",
            "The Reaper's Toll",
            "Death Cleaver",
            "Executioner's Justice",
            "Lycander's Aim",
            "Eaglehorn",
            "Ondal's Wisdom",
            "Stormspire",
            "Titan's Revenge",
            "Ghostflame",
            "Demon Limb",
            "Blade of Ali Baba",
            "Crescent Moon",
            "Doombringer",
            "Earthshaker",
            "Famine",
            "Hand of Blessed Light",
            "Mang Song's Lesson",
            "Razor's Edge",
            "Blackbog's Sharp",
            "Firelizard's Talon",
            "Stormbringer",
            "Widowmaker",
            "Bane",
            "Dragon Talon",
            "Gloomhorn",
            "Moonlight Song",
            "Skull Reaper",
            "Guardian's Edge",
            "Stone Crusher",
            "Hammer's Blaze",
            "Reaper's Touch",
            "Gravelock's Might",
            "Soulrender",
            "Wraithblade",
            "Grimreaper",
            "Nightscythe",
            "Darkfang",
            "Bloodreaver",
            "Shadowstrike",
            "Voidedge",
            "Bonecleaver",
            "Hellslayer",
            "Deathspike",
            "Plaguereaper",
            "Spectralblade",
            "Abyssalaxe",
            "Ghoulrazor",
            "Dreadscythe",
            "Graveblade",
            "Eclipsereaver",
            "Phantomcleaver",
            "Necrofang",
            "Soulcleaver",
            "Voidreaver",
            "Hellblade",
            "Sorrowedge",
            "Tombfang",
            "Wormrazor",
            "Spiritblade",
            "Cryptedge",
            "Gloomscythe",
            "Charnelaxe",
            "Baneedge",
            "Grimfang",
            "Malicereaver",
            "Nightblade",
            "Bloodfang",
            "Wraithspike",
            "Darkreaver",
            "Hellrazor",
            "Soulblade",
            "Deathfang",
            "Ghastreaver",
            "Shadowedge",
            "Voidfang",
            "Doomspike",
            "Spiritrazor",
            "Torturefang",
            "Eclipsescythe",
            "Sorrowspike",
            "Necroedge",
            "Mourningblade"
        ]
        epic_shield_names = [
            "Doomguard",
            "Deathward",
            "Stormcrest",
            "Windshield",
            "Glimmershield",
            "Boneward",
            "Hellgaze",
            "Flameguard",
            "Frostwall",
            "Granddefender",
            "Astreon's Defiance",
            "Lightbearer",
            "Bloodbane",
            "Earthguard",
            "Widowmaker",
            "Azurebane",
            "Reaper's Bulwark",
            "Deathclaw Aegis",
            "Executioner's Resolve",
            "Lycander's Protectorate",
            "Eagleeye",
            "Ondal's Sanctuary",
            "Stormbreaker",
            "Titan's Bastion",
            "Ghostward",
            "Demonhide Barrier",
            "Blade Sentinel",
            "Crescent Moon",
            "Doombreaker",
            "Earthbreaker",
            "Famine's Barrier",
            "Hand of the Guardian",
            "Mang Song's Defense",
            "Razor's Edge",
            "Blackbog's Shield",
            "Firelizard's Embrace",
            "Stormbringer",
            "Widow's Embrace",
            "Banebearer",
            "Dragon's Roar",
            "Gloomwall",
            "Moonshadow",
            "Skullguard",
            "Guardian's Shield",
            "Stonecrusher",
            "Hammer's Might",
            "Reaper's Guard",
            "Gravelock's Deflector",
            "Doombringer",
            "Nightfall",
            "Shadowguard",
            "Graveward",
            "Nightbarrier",
            "Hollowbulwark",
            "Darkwall",
            "Voidshield",
            "Sorrowward",
            "Bloodguard",
            "Deathbarrier",
            "Plaguebulwark",
            "Grimward",
            "Soulwall",
            "Specterbarrier",
            "Necroshield",
            "Shadewall",
            "Bonebarrier",
            "Abyssguard",
            "Tombwall",
            "Hellshield",
            "Gorebarrier",
            "Blackwall",
            "Dreadguard",
            "Skullbarrier",
            "Eclipseguard",
            "Malicewall",
            "Ghoulbarrier",
            "Wraithshield",
            "Doomguard",
            "Shadowshield",
            "Phantombarrier",
            "Deathguard",
            "Cryptwall",
            "Soulbarrier",
            "Mourningguard",
            "Ghastwall",
            "Wormbarrier",
            "Sorrowguard",
            "Corpsewall",
            "Nightguard",
            "Spiritbarrier",
            "Tortureshield",
            "Charnelwall",
            "Hellguard",
            "Bloodshield",
            "Rotbarrier",
            "Gloomguard",
            "Banewall",
            "Graveguard",
            "Voidbarrier"
        ]
        epic_jewelry_names = [
            "Shadowfang",
            "Soulstone",
            "Bloodmoon",
            "Doomgrip",
            "Runeheart",
            "Darkstar",
            "Hellfire",
            "Skullbane",
            "Voidshard",
            "Netherfire",
            "Dreadshadow",
            "Ebonheart",
            "Abyssal Eye",
            "Doomwhisper",
            "Wraithcoil",
            "Chaosbane",
            "Twilight Edge",
            "Soulkeeper",
            "Fateshadow",
            "Voidgaze",
            "Deathshroud",
            "Nightfall",
            "Eldritch Veil",
            "Bloodbane",
            "Ghoulclaw",
            "Bonechill",
            "Shadowveil",
            "Sorrowblade",
            "Cryptfire",
            "Darkmoon",
            "Hellforged",
            "Spectral",
            "Necrofury",
            "Gravetouch",
            "Wraithheart",
            "Dreadstorm",
            "Gloomshroud",
            "Shadowflame",
            "Doomfury",
            "Blazeclaw",
            "Abyssal Warden",
            "Voidlash",
            "Bloodthorn",
            "Soulreaper",
            "Phantomstrike",
            "Cursedheart",
            "Eclipseshard",
            "Darkmantle",
            "Hollowsoul",
            "Deathgaze",
            "Cryptborn",
            "Nightshadow",
            "Grimfire",
            "Doomshroud",
            "Spectral Bind",
            "Bonechill",
            "Soulweaver",
            "Graveclasp",
        ]
        new_name = self.name
        allocated_attributes = {
            health: self.health,
            critical_strike_chance: self.critical_strike_chance,
            critical_strike_damage: self.critical_strike_damage,
            luck: self.luck,
            willpower: self.willpower,
            strength: self.strength,
            dreadmight: self.dreadmight,
            agility: self.agility,
            intelligence: self.intelligence
        }.compact
        # Determine if the item is Epic (has 3 attributes)
        if allocated_attributes.length == 3
            case self.item_type
                when "Chest", "Head", "Hands", "Feet", "Waist"
                    new_name = epic_armor_names.sample
                when "One-handed Weapon", "Two-handed Weapon"
                    new_name = epic_weapon_names.sample
                when "Shield"
                    new_name = epic_shield_names.sample
                when "Finger", "Neck"
                    new_name = epic_jewelry_names.sample
            end
        else
            attribute_names = allocated_attributes.keys
            if attribute_names.length == 1
                attribute = attribute_names.first
                new_name = "#{prefixes[attribute]} #{new_name}"
            elsif attribute_names.length >= 2
                first_attribute = attribute_names[0]
                second_attribute = attribute_names[1]
                prefix_name = prefixes[first_attribute]
                suffix_name = suffixes[second_attribute]
                new_name = "#{prefix_name} #{new_name} #{suffix_name}"
            end
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
        duped_item.armor = (self.armor * (rand(0.8..1.0))).to_i if self.armor.present?
        duped_item.magic_resistance = (self.magic_resistance * (rand(0.8..1.0))).to_i if self.magic_resistance.present?
        if self.rarity == "Legendary"
            duped_item.health = (self.health * (rand(0.8..1.0))).to_i if self.health.present?
            duped_item.strength = (self.strength * (rand(0.8..1.0))).to_i if self.strength.present?
            duped_item.intelligence = (self.intelligence * (rand(0.8..1.0))).to_i if self.intelligence.present?
            duped_item.agility = (self.agility * (rand(0.8..1.0))).to_i if self.agility.present?
            duped_item.dreadmight = (self.dreadmight * (rand(0.8..1.0))).to_i if self.dreadmight.present?
            duped_item.luck = (self.luck * (rand(0.8..1.0))).to_i if self.luck.present?
            duped_item.willpower = (self.willpower * (rand(0.8..1.0))).to_i if self.willpower.present?
            duped_item.global_damage = (self.global_damage * (rand(0.8..1.0))) if self.global_damage.present?
            duped_item.critical_strike_chance = (self.critical_strike_chance * (rand(0.8..1.0))) if self.critical_strike_chance.present?
            duped_item.critical_strike_damage = (self.critical_strike_damage * (rand(0.8..1.0))) if self.critical_strike_damage.present?
        else
            duped_item.randomize_attributes
        end
        duped_item.generated_item = true
        attach_image_to_item(duped_item, self.item_image.blob.key)
        duped_item.set_initial_stats
        duped_item.save
        duped_item
    end

    def self.dupe_and_set_merchant_item(item)
        duped_item = item.dupe_item
        duped_item.merchant_item = true
        duped_item.save
    end

    def self.set_merchant_items(character)
        # Determine the armor types to show in shop based on character class
        weapon_types =
                    case character.character_class
                        when 'warrior'
                            ["Sword", "Axe", "Small Shield", "Great Shield"]
                        when 'paladin'
                            ["Sword", "Mace", "Small Shield", "Great Shield"]
                        when 'deathwalker'
                            ["Sword", "Axe"]
                        when 'nightstalker'
                            ["Sword", "Dagger"]
                        when 'mage', 'acolyte'
                            ["Sword", "Staff", "Dagger", "Small Shield"]
                    end
        armor_types =
                    case character.character_class
                        when 'warrior', 'deathwalker', 'paladin'
                            ["Plate", "Belt"]
                        when 'nightstalker'
                            ["Leather", "Belt"]
                        when 'mage', 'acolyte'
                            ["Cloth", "Belt"]
                    end

        Item.where(item_type: ["One-handed Weapon", "Two-handed Weapon", "Shield"], item_class: [weapon_types], merchant_item: false, generated_item: false)
            .order('RANDOM()')
            .limit(5)
            .each { |item| dupe_and_set_merchant_item(item) }
        Item.where(item_type: ["Head", "Chest", "Feet", "Waist", "Hands"], item_class: [armor_types], merchant_item: false, generated_item: false)
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
