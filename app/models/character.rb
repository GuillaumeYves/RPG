class Character < ApplicationRecord
    belongs_to :user

    belongs_to :hunt, optional: true, dependent: :destroy
    has_one :accepted_hunt, class_name: 'Hunt', foreign_key: 'character_id'

    has_one :inventory, dependent: :destroy
    has_many :items, dependent: :destroy

    belongs_to :main_hand, class_name: 'Item', foreign_key: 'main_hand', optional: true
    belongs_to :off_hand, class_name: 'Item', foreign_key: 'off_hand', optional: true
    belongs_to :head, class_name: 'Item', foreign_key: 'head', optional: true
    belongs_to :neck, class_name: 'Item', foreign_key: 'neck', optional: true
    belongs_to :chest, class_name: 'Item', foreign_key: 'chest', optional: true
    belongs_to :hands, class_name: 'Item', foreign_key: 'hands', optional: true
    belongs_to :waist, class_name: 'Item', foreign_key: 'waist', optional: true
    belongs_to :feet, class_name: 'Item', foreign_key: 'feet', optional: true
    belongs_to :finger1, class_name: 'Item', foreign_key: 'finger1', optional: true
    belongs_to :finger2, class_name: 'Item', foreign_key: 'finger2', optional: true

    has_many :skills, dependent: :destroy

    has_one_attached :race_image

    before_save :ensure_non_negative_attributes

    validates :character_class, presence: true
    validates :race, presence: true
    validates :gender, presence: true
    validates :character_name, presence: true, uniqueness: true, length: { minimum: 4, maximum: 20 }
    validates :level, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :experience, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :skill_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    validate :max_characters, on: :create
    validate :valid_character_name, on: :create

    attr_accessor :buffed_attack, :buffed_spellpower, :buffed_necrosurge, :buffed_armor, :buffed_magic_resistance, :buffed_critical_strike_chance, :buffed_critical_strike_damage
    attr_accessor :took_damage
    attr_accessor :piety
    attr_accessor :nullify
    attr_accessor :ephemeral_rebirth
    attr_accessor :temp_health

    def self.recovery
        Character.find_each do |character|
            character.recover_energy
            character.recover_health
        end
    end

    def recover_health
        return if self.total_health >= self.total_max_health

        recovered_health = (total_max_health * 0.10).to_i
        self.total_health += recovered_health
        self.total_health = total_max_health if total_health > total_max_health
        save
    end

    def recover_energy
        return if self.energy >= self.max_energy

        self.energy += 10
        self.energy = self.max_energy if self.energy > self.max_energy
        save
    end

    def create_inventory
        Inventory.create(character: self)
    end

    def set_race_image
        case race
        when 'human'
            image_path = case gender
                        when 'female'
                        'female_human.jpg'
                        else
                        'human.jpg'
                        end
        when 'elf'
            image_path = case gender
                        when 'female'
                        'female_elf.jpg'
                        else
                        'elf.jpg'
                        end
        when 'dwarf'
            image_path = case gender
                        when 'female'
                        'female_dwarf.jpg'
                        else
                        'dwarf.jpg'
                        end
        when 'troll'
            image_path = case gender
                        when 'female'
                        'female_troll.jpg'
                        else
                        'troll.jpg'
                        end
        when 'orc'
            image_path = case gender
                        when 'female'
                        'female_orc.jpg'
                        else
                        'orc.jpg'
                        end
        when 'goblin'
            image_path = case gender
                        when 'female'
                        'female_goblin.jpg'
                        else
                        'goblin.jpg'
                        end
        end
        # Check if image is already attached before attaching
        unless self.race_image.attached?
            self.race_image.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'races', image_path)), filename: File.basename(image_path), content_type: 'image/jpeg')
        end
    end

    def set_default_values_for_stat_bonuses
        self.strength_bonus = 0
        self.intelligence_bonus = 0
        self.agility_bonus = 0
        self.dreadmight_bonus = 0
    end

    def set_default_values_for_total_stats
        if self.character_class == 'rogue' && skills.find_by(name: 'Swift Movements', unlocked: true)
            self.total_attack = ((self.attack + self.agility_bonus) + (self.attack * self.paragon_attack))
        else
            self.total_attack = ((self.attack + self.strength_bonus) + (self.attack * self.paragon_attack))
        end
        self.total_spellpower = ((self.spellpower + self.intelligence_bonus) + self.paragon_spellpower)
        if self.character_class == 'paladin' && skills.find_by(name: 'Piety', unlocked: true)
            self.total_armor = ((self.armor + self.strength_bonus) + (self.armor * self.paragon_armor))
        else
            self.total_armor = (self.armor + (self.armor * self.paragon_armor))
        end
        self.total_necrosurge = (self.necrosurge + self.dreadmight_bonus)
        if self.character_class == 'mage' && skills.find_by(name: 'Book of Edim', unlocked: true)
            self.total_magic_resistance = ((self.magic_resistance + self.intelligence_bonus) + (self.magic_resistance * self.paragon_magic_resistance))
        else
            self.total_magic_resistance = (self.magic_resistance + (self.magic_resistance * self.paragon_magic_resistance))
        end
        self.total_critical_strike_chance = ((self.critical_strike_chance + calculate_luck_bonus) + self.paragon_critical_strike_chance)
        self.total_critical_strike_damage = (self.critical_strike_damage + self.paragon_critical_strike_damage)
        self.max_health = self.health
        if self.character_class == 'warrior' && skills.find_by(name: 'Juggernaut', unlocked: true)
            self.total_health = ((self.health + self.strength_bonus) + (self.health * self.paragon_total_health))
        else
            self.total_health = (self.health + (self.health * self.paragon_total_health))
        end
        self.total_max_health = self.total_health
        self.total_global_damage = (self.global_damage + self.paragon_global_damage)

        self.total_attack += self.elixir_attack
        self.total_armor += self.elixir_armor
        self.total_spellpower += self.elixir_spellpower
        self.total_magic_resistance += self.elixir_magic_resistance
    end

    def set_default_values_for_buffed_stats
        self.buffed_attack = 0
        self.buffed_spellpower = 0
        self.buffed_armor = 0
        self.buffed_necrosurge = 0
        self.buffed_magic_resistance = 0
        self.buffed_critical_strike_chance = 0.0
        self.buffed_critical_strike_damage = 0.0
    end

    def apply_combat_skills
        if self.character_class == 'warrior'
            skills.where(skill_type: "combat", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'mage'
            skills.where(skill_type: "combat", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'rogue'
            skills.where(skill_type: "combat", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'paladin'
            skills.where(skill_type: "combat", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'deathwalker'
            skills.where(skill_type: "combat", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        else return
        end
    end

    def apply_passive_skills
        modify_stats_based_on_attributes
        set_default_values_for_total_stats
        if self.character_class == 'warrior'
            skills.where(skill_type: "passive", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'mage'
            skills.where(skill_type: "passive", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'rogue'
            skills.where(skill_type: "passive", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'paladin'
            skills.where(skill_type: "passive", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'deathwalker'
            skills.where(skill_type: "passive", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        else return
        end
    end

    def apply_trigger_skills
        if self.character_class == 'warrior'
            skills.where(skill_type: "trigger", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'mage'
            skills.where(skill_type: "trigger", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'rogue'
            skills.where(skill_type: "trigger", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'paladin'
            skills.where(skill_type: "trigger", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        elsif self.character_class == 'deathwalker'
            skills.where(skill_type: "trigger", unlocked: true).each do |skill|
            instance_eval(skill.effect) if skill.effect.present?
            end
        else return
        end
    end

    # Add methods to modify stats based on race
    def modify_stats_based_on_race
        case race
        when 'human'
            # Stats for humans are defaults
        when 'elf'
            # Modify stats for elf race
            self.health -= 3
            self.strength -= 3
            self.intelligence += 2
            self.agility += 2
            self.dreadmight -= 3
            self.willpower -= 2
        when 'dwarf'
            # Modify stats for dwarf race
            self.health -= 4
            self.strength -= 2
            self.intelligence += 1
            self.agility -= 1
            self.dreadmight -= 2
            self.willpower += 1
        when 'troll'
            # Modify stats for troll race
            self.health += 5
            self.strength += 1
            self.intelligence += 1
            self.agility -= 3
            self.dreadmight -= 1
            self.willpower += 1
        when 'orc'
            # Modify stats for orc race
            self.health += 3
            self.strength += 4
            self.intelligence -= 3
            self.agility -= 3
            self.dreadmight += 1
            self.willpower += 1
        when 'goblin'
            # Modify stats for goblin race
            self.health -= 5
            self.strength -= 2
            self.intelligence += 2
            self.agility += 2
            self.dreadmight += 1
            self.willpower -= 2
        end
    end

    # Add methods to modify attributes based on class
    def modify_attributes_based_on_class
        case character_class
        when 'warrior'
            # Modify attributes for warrior class
            self.attack += 3
            self.spellpower -= 3
            self.necrosurge -= 2
            self.armor += 1
            self.magic_resistance -= 2
        when 'mage'
            # Modify attributes for mage class
            self.attack -= 3
            self.spellpower += 3
            self.necrosurge -= 2
            self.armor -= 2
            self.magic_resistance += 2
        when 'rogue'
            # Modify attributes for rogue class
            self.attack += 2
            self.spellpower -= 1
            self.necrosurge -= 1
            self.armor -= 1
            self.magic_resistance -= 1
        when 'paladin'
            # Modify attributes for paladin class
            self.attack += 2
            self.spellpower += 1
            self.necrosurge -= 3
            self.armor += 1
            self.magic_resistance += 1
        when 'deathwalker'
            # Modify attributes for deathwalker class
            self.attack -= 1
            self.spellpower -= 3
            self.necrosurge += 4
            self.armor -= 2
            self.magic_resistance -= 2
        end
    end

    def revert_stat_bonuses_based_on_attributes
        self.strength_bonus = 0
        self.intelligence_bonus = 0
        self.agility_bonus = 0
        self.dreadmight_bonus = 0
        calculate_luck_bonus
        evasion
        ignore_pain_chance
    end

    def modify_stats_based_on_attributes
        revert_stat_bonuses_based_on_attributes
        calculate_strength_bonus
        calculate_intelligence_bonus
        calculate_agility_bonus
        calculate_dreadmight_bonus
        calculate_luck_bonus
        evasion
        ignore_pain_chance
    end

    def calculate_strength_bonus
        if self.character_class == 'warrior' && skills.find_by(name: 'Juggernaut', unlocked: true)
            self.strength_bonus = (self.strength * 0.1)
        else
            self.strength_bonus = (self.strength * 0.04)
        end
    end

    def calculate_intelligence_bonus
        if self.character_class == 'mage' && skills.find_by(name: 'Enlighten', unlocked: true)
            self.intelligence_bonus = (self.intelligence * 0.1)
        else
            self.intelligence_bonus = (self.intelligence * 0.04)
        end
    end

    def calculate_agility_bonus
        self.agility_bonus = (self.agility * 0.04)
    end

    def calculate_dreadmight_bonus
        self.dreadmight_bonus = (self.dreadmight * 0.04)
    end

    def calculate_luck_bonus
        self.luck * 0.05
    end

    def evasion
        if self.character_class == 'warrior' && skills.find_by(name: 'Undeniable', unlocked: true)
            evasion = 0.0
        else
            self.agility * 0.03
        end
    end

    def ignore_pain_chance
        if self.character_class == 'warrior' && skills.find_by(name: 'Undeniable', unlocked: true)
            ignore_pain_chance = 0.0
        else
            self.willpower * 0.03
        end
    end

    def assign_skills_based_on_class
        case character_class
            when 'warrior'
                # Seed warrior skills
                warrior_skills_seeder = WarriorSkillsSeeder.new(self)
                warrior_skills_seeder.seed_skills
            when 'mage'
                # Seed mage skills
                mage_skills_seeder = MageSkillsSeeder.new(self)
                mage_skills_seeder.seed_skills
            when 'rogue'
                # Seed rogue skills
                rogue_skills_seeder = RogueSkillsSeeder.new(self)
                rogue_skills_seeder.seed_skills
            when 'paladin'
                # Seed paladin skills
                paladin_skills_seeder = PaladinSkillsSeeder.new(self)
                paladin_skills_seeder.seed_skills
            when 'deathwalker'
                # Seed deathwalker skills
                deathwalker_skills_seeder = DeathwalkerSkillsSeeder.new(self)
                deathwalker_skills_seeder.seed_skills
        end
    end

    def revert_stats_based_on_item(item)
        # Subtract stats of the unequipped item
        self.attack -= item.attack unless item.attack.nil?
        self.necrosurge -= item.necrosurge unless item.necrosurge.nil?
        self.health -= item.health unless item.health.nil?
        self.armor -= item.armor unless item.armor.nil?
        self.spellpower -= item.spellpower unless item.spellpower.nil?
        self.magic_resistance -= item.magic_resistance unless item.magic_resistance.nil?
        self.strength -= item.strength unless item.strength.nil?
        self.intelligence -= item.intelligence unless item.intelligence.nil?
        self.agility -= item.agility unless item.agility.nil?
        self.dreadmight -= item.dreadmight unless item.dreadmight.nil?
        self.luck -= item.luck unless item.luck.nil?
        self.willpower -= item.willpower unless item.willpower.nil?
        self.critical_strike_chance -= item.critical_strike_chance unless item.critical_strike_chance.nil?
        self.critical_strike_damage -= item.critical_strike_damage unless item.critical_strike_damage.nil?
        self.global_damage -= item.global_damage unless item.global_damage.nil?
    end

    def modify_stats_based_on_item(item)
        # Adds stats of the equipped item
        self.attack += item.attack unless item.attack.nil?
        self.necrosurge += item.necrosurge unless item.necrosurge.nil?
        self.health += item.health unless item.health.nil?
        self.armor += item.armor unless item.armor.nil?
        self.spellpower += item.spellpower unless item.spellpower.nil?
        self.magic_resistance += item.magic_resistance unless item.magic_resistance.nil?
        self.strength += item.strength unless item.strength.nil?
        self.intelligence += item.intelligence unless item.intelligence.nil?
        self.agility += item.agility unless item.agility.nil?
        self.dreadmight += item.dreadmight unless item.dreadmight.nil?
        self.luck += item.luck unless item.luck.nil?
        self.willpower += item.willpower unless item.willpower.nil?
        self.critical_strike_chance += item.critical_strike_chance unless item.critical_strike_chance.nil?
        self.critical_strike_damage += item.critical_strike_damage unless item.critical_strike_damage.nil?
        self.global_damage += item.global_damage unless item.global_damage.nil?
    end

    def level_up
        # Increase level
        update(level: level + 1)

        # Check if skill point should be added at specific levels
        if [25, 50, 75, 100].include?(level)
            self.skill_points += 1
        end
        if self.level >= 100
            self.paragon_points += 1
        end

        # Modify health based on character class
        case character_class
        when 'warrior'
            self.health += 5
        when 'mage'
            self.health += 3
        when 'rogue'
            self.health += 4
        when 'paladin'
            self.health += 6
        when 'deathwalker'
            self.health += 7
        end

        self.modify_stats_based_on_attributes
        self.apply_passive_skills

        # Calculate the remaining experience after leveling up
        remaining_experience = experience - required_experience_for_next_level
        update_required_experience_for_next_level

        # Update the character's experience with the remaining experience
        update(experience: remaining_experience)
        save
    end

    def update_required_experience_for_next_level
        self.required_experience_for_next_level = (500 * (1.1 ** (self.level - 1))).round
    end

    def update_elixir_effect
        return unless elixir_active == true

        active_elixirs = Item.where(id: active_elixir_ids)

        active_elixirs.each do |elixir|
            case elixir.name
            when "Elixir of Might"
                update(elixir_attack: (self.total_attack * elixir.potion_effect).round)
            when "Elixir of Power"
                update(elixir_spellpower: (self.total_spellpower * elixir.potion_effect).round)
            when "Elixir of Decay"
                update(elixir_necrosurge: (self.total_necrosurge * elixir.potion_effect).round)
            when "Elixir of Fortitude"
                update(elixir_armor: (self.total_armor * elixir.potion_effect).round)
            when "Elixir of Knowledge"
                update(elixir_magic_resistance: (self.total_magic_resistance * elixir.potion_effect).round)
            when "Elixir of Potency"
                update(elixir_global_damage: (self.elixir_global_damage + elixir.potion_effect).round)
            when "Elixir of Vitality"
                update(elixir_total_health: (self.total_health * elixir.potion_effect).round)
            end
        end
    end

    def remaining_elixir_time(elixir)
        return { remaining_time: 0 } unless elixir.present?

        if elixir.is_a?(Item) && elixir.item_type == 'Elixir'
            expiration_time = elixir.created_at.to_i + elixir.duration.seconds.to_i
        else
            expiration_time = elixir.elixir_applied_at.to_i + elixir.elixir_duration.seconds.to_i
        end

        remaining_time = [expiration_time - Time.current.to_i, 0].max
        { remaining_time: remaining_time, expiration_time: expiration_time }
    end

    def self.expired_elixirs
        characters_with_expired_elixir = Character.where("elixir_active = ? AND (current_timestamp - elixir_applied_at) >= elixir_duration * interval '1 second'", true)

        characters_with_expired_elixir.each do |character|
            expired_elixirs = Item.where(id: character.active_elixir_ids)

            expired_elixirs.each do |elixir|
            if (Time.current - elixir.elixir_applied_at) >= elixir.elixir_duration
                # This elixir is expired, remove it
                character.active_elixir_ids.delete(elixir.id)
                character.save
            end
        end

            # Now update the character's attributes based on the remaining active elixirs
            character.update(
            elixir_active: character.active_elixir_ids.present?,
            elixir_applied_at: character.active_elixir_ids.present? ? Time.current : nil,
            elixir_duration: character.active_elixir_ids.present? ? expired_elixirs.last.elixir_duration : nil
            )

            character.modify_stats_based_on_attributes
            character.apply_passive_skills
            character.save
        end
    end

    def add_item_to_inventory(item)
        inventory = Inventory.find_or_create_by(character_id: id)
        item.update(inventory_id: inventory.id)
    end

    def remove_item_from_inventory(item)
        item.update(inventory_id: nil)
    end

    def can_equip?(item)
        if self.level >= item.level_requirement
            case item.item_class
                when 'Sword'
                    # All characters can equip one-handed swords
                    return true if item.item_type == 'One-handed Weapon'
                    # For two-handed swords, restrict to warriors and paladins
                    return true if item.item_type == 'Two-handed Weapon' && %w[warrior paladin deathwalker].include?(character_class)
                    errors.add(:base, "Only Warriors, Paladins and Deathwalkers can equip Two-handed Swords.")
                    return false
                when 'Great Shield'
                    return true if character_class == 'paladin'
                    errors.add(:base, "Only Paladins can equip Great Shields.")
                    return false
                when 'Small Shield'
                    return true if %w[warrior paladin mage].include?(character_class)
                    errors.add(:base, "Only Warriors, Paladins and Mages can equip Small Shields.")
                    return false
                when 'Axe'
                    return true if character_class == 'warrior'
                    errors.add(:base, "Only Warriors can equip Axes.")
                    return false
                when 'Mace'
                    return true if character_class == 'paladin'
                    errors.add(:base, "Only Paladins can equip Maces.")
                    return false
                when 'Dagger'
                    return true if character_class == 'rogue'
                    errors.add(:base, "Only Rogues can equip Daggers.")
                    return false
                when 'Staff'
                    return true if character_class == 'mage'
                    errors.add(:base, "Only Mages can equip Staves.")
                    return false
                when 'Plate'
                    return true if %w[warrior paladin].include?(character_class)
                    errors.add(:base, "Only Warriors and Paladins can equip Plate.")
                    return false
                when 'Leather'
                    return true if character_class == 'rogue'
                    errors.add(:base, "Only Rogues can equip leather.")
                    return false
                when 'Cloth'
                    return true if %w[mage deathwalker].include?(character_class)
                    errors.add(:base, "Only Mages and Deathwalkers can equip cloth.")
                    return false
                when 'Ring'
                    return true
                when 'Amulet'
                    return true
                when 'Belt'
                    return true
            end
        else
            errors.add(:base, "You do not have the required level to equip that item.")
            return false
        end
    end

    def unequip_main_hand(main_hand)
        return unless self.main_hand
        # Add the two-handed weapon back to the inventory
        add_item_to_inventory(self.main_hand)
        # Modify stats based on the unequipped two-handed weapon
        revert_stats_based_on_item(self.main_hand)
        # Clear the character's main hand
        self.main_hand = nil
    end

    def unequip_off_hand(off_hand)
        return unless self.off_hand
        # Add the two-handed weapon back to the inventory
        add_item_to_inventory(self.off_hand)
        # Modify stats based on the unequipped two-handed weapon
        revert_stats_based_on_item(self.off_hand)
        # Clear the character's main hand
        self.off_hand = nil
    end

    def equip_one_handed_weapon(item)
        # Case 1: No existing weapon in the main hand or off hand
        if self.main_hand.nil? && self.off_hand.nil?
            Rails.logger.debug("################## Entering Case 1")
            self.main_hand = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        # Case 2: Main hand but no off hand
        elsif self.main_hand.present? && self.off_hand.nil?
            Rails.logger.debug("################## Entering Case 2")
            if self.main_hand.item_type == 'One-handed Weapon'
                if (self.main_hand.item_class == 'Dagger' || self.main_hand.item_class == 'Sword') && self.character_class == 'rogue'
                    Rails.logger.debug("################## Case 2 - Character is a rogue and item is either sword or dagger")
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                    return
                elsif self.main_hand.item_class == 'Sword' && self.character_class == 'deathwalker'
                    Rails.logger.debug("################## Case 2 - Character is a deathwalker and item is a sword")
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                    return
                end
                unequip_main_hand(self.main_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.main_hand.item_type == 'Two-handed Weapon'
                unequip_main_hand(self.main_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        # Case 3: No main hand but off hand is present
        elsif self.main_hand.nil? && self.off_hand.present?
            Rails.logger.debug("################## Entering Case 3")
            if self.off_hand.item_type == 'Shield'
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                if self.character_class == 'rogue' && (item.item_class == 'Dagger' || item.item_class == 'Sword')
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                end
                unequip_off_hand(self.off_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon'
                unequip_off_hand(self.off_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        # Case 4: Both main hand and off hand have weapons
        elsif self.main_hand.present? && self.off_hand.present?
            Rails.logger.debug("################## Entering Case 4")
            if self.off_hand.item_type == 'Shield'
                unequip_main_hand(self.main_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                if (self.main_hand.item_class == 'Dagger' || self.main_hand.item_class == 'Sword') && self.character_class == 'rogue'
                    unequip_off_hand(self.off_hand)
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                    return
                end
                unequip_main_hand(self.main_hand)
                unequip_off_hand(self.off_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon'
                unequip_main_hand(self.main_hand)
                unequip_off_hand(self.off_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        end
    end

    def equip_shield(item)
        # Case 1: No existing weapon in the off hand or main hand
        if self.main_hand.nil? && self.off_hand.nil?
            Rails.logger.debug("################## Entering Case 1")
            self.off_hand = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        # Case 2: Main hand but no off hand
        elsif self.main_hand.present? && self.off_hand.nil?
            Rails.logger.debug("################## Entering Case 2")
            if self.main_hand.item_type == 'One-handed Weapon'
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.main_hand.item_type == 'Two-handed Weapon'
                if skills.find_by(name: 'Divine Strength', unlocked: true).present?
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                else
                    unequip_main_hand(self.main_hand)
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                end
            end
        # Case 3: Main hand and off hand
        elsif self.main_hand.present? && self.off_hand.present?
            Rails.logger.debug("################## Entering Case 3")
            if self.off_hand.item_type == 'Shield'
                unequip_off_hand(self.off_hand)
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                unequip_off_hand(self.off_hand)
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon'
                unequip_main_hand(self.main_hand)
                unequip_off_hand(self.off_hand)
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        end
    end

    def equip_two_handed_weapon(item)
        # Case 1: No existing weapons
        if self.main_hand.nil? && self.off_hand.nil?
            Rails.logger.debug("################## Entering Case 1")
            self.main_hand = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        # Case 2: Only main hand has a weapon
        elsif self.main_hand.present? && self.off_hand.nil?
            Rails.logger.debug("################## Entering Case 2")
            if self.main_hand.item_type == 'One-handed Weapon'
                    # Replace the existing one-handed weapon in main hand
                    unequip_main_hand(self.main_hand)
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
            elsif self.main_hand.item_type == 'Two-handed Weapon'
                if skills.find_by(name: 'Forged in Battle', unlocked: true).present?
                    # Equip the weapon in the off hand if two-handed and Forged in Battle talent
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                else
                    unequip_main_hand(self.main_hand)
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                end
            else
                errors.add(:base, "You cannot dual wield Two-handed weapons.")
            end
        # Case 3: Only off hand has a weapon
        elsif self.main_hand.nil? && self.off_hand.present?
            Rails.logger.debug("################## Entering Case 3")
            if self.off_hand.item_type == 'Shield'
                if skills.find_by(name: 'Divine Strength', unlocked: true).present?
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                else
                    unequip_off_hand(self.off_hand)
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                end
            elsif self.off_hand.item_type == 'One-handed Weapon'
                # Remove the main hand and off hand then equip the item in main hand
                unequip_off_hand(self.off_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon' && skills.find_by(name: 'Forged in Battle', unlocked: true)
                # Equip the item in main hand if Forged in Battle talent
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            else
                errors.add(:base, "You cannot dual wield Two-handed weapons.")
            end
        # Case 4: Both main hand and off hand have weapons
        elsif self.main_hand.present? && self.off_hand.present?
            Rails.logger.debug("################## Entering Case 4")
            if self.off_hand.item_type == 'Shield'
                if skills.find_by(name: 'Divine Strength', unlocked: true).present?
                    unequip_main_hand(self.main_hand)
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                else
                    unequip_main_hand(self.main_hand)
                    unequip_off_hand(self.off_hand)
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                end
            elsif self.off_hand.item_type == 'One-handed Weapon'
                # Remove the main hand and off hand then equip the item
                unequip_main_hand(self.main_hand)
                unequip_off_hand(self.off_hand)
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon' && skills.find_by(name: 'Forged in Battle', unlocked: true)
                # Equip the item in off hand if Forged in Battle talent
                unequip_off_hand(self.off_hand)
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        end
    end

    def unequip_helmet(head)
        return unless self.head
        # Add the helmet back to the inventory
        add_item_to_inventory(head)
        # Modify stats based on the removed helmet
        revert_stats_based_on_item(head)
        # Clear the character's helmet
        self.head = nil
    end
    def equip_helmet(item)
        if self.head.nil?
            # No existing helmet
            self.head = item
            # Remove the helmet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped helmet
            modify_stats_based_on_item(item)
        else
            # Replace the existing helmet
            unequip_helmet(self.head)
            self.head = item
            # Remove the new helmet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped helmet
            modify_stats_based_on_item(item)
        end
    end

    def unequip_chest(chest)
        return unless self.chest
        # Add the chest back to the inventory
        add_item_to_inventory(chest)
        # Modify stats based on the removed chest
        revert_stats_based_on_item(chest)
        # Clear the character's chest
        self.chest = nil
    end
    def equip_chest(item)
        if self.chest.nil?
            # No existing chest
            self.chest = item
            # Remove the chest from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped chest
            modify_stats_based_on_item(item)
        else
            # Replace the existing chest
            unequip_chest(self.chest)
            self.chest = item
            # Remove the new chest from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped chest
            modify_stats_based_on_item(item)
        end
    end

    def unequip_legs(legs)
        return unless self.legs
        # Add the legs back to the inventory
        add_item_to_inventory(self.legs)
        # Modify stats based on the removed legs
        revert_stats_based_on_item(self.legs)
        # Clear the character's legs
        self.legs = nil
    end

    def unequip_amulet(neck)
        return unless self.neck
        add_item_to_inventory(self.neck)
        revert_stats_based_on_item(self.neck)
        self.neck_item = nil
    end
    def equip_amulet(item)
        if self.neck.nil?
            self.neck = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_amulet(self.neck)
            self.neck = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_ring(finger1)
        return unless self.finger1
        add_item_to_inventory(self.finger1)
        revert_stats_based_on_item(self.finger1)
        self.finger1 = nil
    end
    def equip_ring(item)
        if self.finger1.nil?
            self.finger1 = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        elsif self.finger2.nil? & self.finger1.present?
            self.finger2 = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_ring(self.finger1)
            self.finger1 = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_waist(waist)
        return unless self.waist
        add_item_to_inventory(self.waist)
        revert_stats_based_on_item(self.waist)
        self.waist = nil
    end
    def equip_waist(item)
        if self.waist.nil?
            self.waist = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_waist(self.waist)
            self.waist = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_hands(hands)
        return unless self.hands
        add_item_to_inventory(self.hands)
        revert_stats_based_on_item(self.hands)
        self.hands_item = nil
    end
    def equip_hands(item)
        if hands.nil?
            self.hands = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_amulet(self.hands)
            self.hands = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_feet(feet)
        return unless self.feet
        add_item_to_inventory(self.feet)
        revert_stats_based_on_item(self.feet)
        self.feet = nil
    end
    def equip_feet(item)
        if self.feet.nil?
            self.feet = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_feet(self.feet)
            self.feet = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    private

    def max_characters
        errors.add(:base, "You can't have more than 3 characters.") if user.characters.count >= 3
    end

    def valid_character_name
        unless character_name.match?(/\A[a-zA-Z0-9]+\z/)
            errors.add(:character_name, 'can only contain letters and numbers.')
        end
    end

    def ensure_non_negative_attributes
        self.strength = [self.strength, 0].max
        self.intelligence = [self.intelligence, 0].max
        self.agility = [self.agility, 0].max
        self.luck = [self.luck, 0].max
        self.willpower = [self.willpower, 0].max
        self.health = [self.health, 0].max
        self.total_armor = [self.total_armor, 0].max
        self.total_magic_resistance = [self.total_magic_resistance, 0].max
        self.total_attack = [self.total_attack, 0].max
        self.total_spellpower = [self.total_spellpower, 0].max
    end
end
