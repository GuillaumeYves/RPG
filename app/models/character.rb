class Character < ApplicationRecord
    belongs_to :user
    belongs_to :guild, optional: true
    belongs_to :hunt, optional: true, dependent: :destroy
    belongs_to :quest, optional: true, dependent: :destroy
    has_one :accepted_hunt, class_name: 'Hunt', foreign_key: 'character_id'
    has_many :accepted_quests, class_name: 'Quest', foreign_key: 'character_id'

    has_one :inventory, dependent: :destroy
    has_many :items, dependent: :destroy

    has_many :combat_results, dependent: :destroy

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

    validate :max_characters, on: :create
    validate :valid_character_name, on: :create

    attr_accessor :buffed_min_attack, :buffed_max_attack, :buffed_min_spellpower, :buffed_max_spellpower, :buffed_min_necrosurge,
    :buffed_max_necrosurge, :buffed_armor, :buffed_magic_resistance, :buffed_critical_strike_chance, :buffed_critical_strike_damage,
    :buffed_damage_reduction, :buffed_critical_resistance, :buffed_fire_resistance, :buffed_cold_resistance, :buffed_lightning_resistance,
    :buffed_poison_resistance

    attr_accessor :took_damage
    attr_accessor :piety
    attr_accessor :nullify
    attr_accessor :ephemeral_rebirth
    attr_accessor :blessing_of_kings
    attr_accessor :deathsbargain

    def self.recovery
        Character.find_each do |character|
            character.recover_energy
            character.recover_health
        end
    end

    def self.cleanup_combat_results
        Character.find_each do |character|
            combat_results_to_keep = character.combat_results.order(created_at: :desc).limit(10)
            combat_results_to_delete = character.combat_results.where.not(id: combat_results_to_keep.ids)
            combat_results_to_delete.destroy_all
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
        when 'morvandir'
            image_path = case gender
                        when 'female'
                        'female_morvandir.jpg'
                        else
                        'morvandir.jpg'
                        end
        end
        # Check if image is already attached before attaching
        unless self.race_image.attached?
            self.race_image.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'races', image_path)), filename: File.basename(image_path), content_type: 'image/jpeg')
        end
    end

    def set_default_values_for_total_stats
        if self.character_class == 'nightstalker' && skills.find_by(name: 'Swift Movements', unlocked: true)
            self.total_min_attack = ((self.min_attack + (self.agility_bonus * 0.80)) + (self.min_attack * self.paragon_attack)).to_i
            self.total_max_attack = ((self.max_attack + (self.agility_bonus * 0.80)) + (self.max_attack * self.paragon_attack)).to_i
        else
            self.total_min_attack = (self.min_attack + (self.strength_bonus) + (self.min_attack * self.paragon_attack)).to_i
            self.total_max_attack = (self.max_attack + (self.strength_bonus) + (self.max_attack * self.paragon_attack)).to_i
        end
        self.total_min_spellpower = (self.min_spellpower + (self.intelligence_bonus * self.paragon_spellpower)).to_i
        self.total_max_spellpower = (self.max_spellpower + (self.intelligence_bonus * self.paragon_spellpower)).to_i
        self.total_min_necrosurge = (self.min_necrosurge + self.dreadmight_bonus).to_i
        self.total_max_necrosurge = (self.max_necrosurge + self.dreadmight_bonus).to_i
        self.total_armor = (self.armor + (self.armor * self.paragon_armor)).to_i
        self.total_magic_resistance = (self.magic_resistance + (self.magic_resistance * self.paragon_magic_resistance)).to_i
        self.total_critical_strike_chance = ((self.critical_strike_chance + calculate_luck_bonus) + self.paragon_critical_strike_chance).to_d
        if self.character_class == 'mage' && skills.find_by(name: 'Book of Edim', unlocked: true)
            self.total_critical_strike_damage = ((self.critical_strike_damage + (self.intelligence_bonus * 0.002)) + self.paragon_critical_strike_damage).to_d
        else
            self.total_critical_strike_damage = (self.critical_strike_damage + self.paragon_critical_strike_damage)
        end
        self.total_damage_reduction = (self.damage_reduction + (self.ignore_pain_chance * 0.002)).to_d
        self.total_critical_resistance = (self.critical_resistance + (self.strength_bonus * 0.05)).to_i
        self.total_fire_resistance = (self.fire_resistance + (self.intelligence_bonus * 0.05)).to_i
        self.total_cold_resistance = (self.cold_resistance + (self.intelligence_bonus * 0.05)).to_i
        self.total_lightning_resistance = (self.lightning_resistance + (self.intelligence_bonus * 0.05)).to_i
        self.total_poison_resistance = (self.poison_resistance + (self.intelligence_bonus * 0.05)).to_i
        self.max_health = self.health
        if self.character_class == 'warrior' && skills.find_by(name: 'Juggernaut', unlocked: true)
            self.total_health = (self.health + (self.strength_bonus)) + (self.health * self.paragon_total_health).to_i
        else
            self.total_health = (self.health + (self.health * self.paragon_total_health)).to_i
        end
        self.total_max_health = self.total_health
        self.total_global_damage = (self.global_damage + self.paragon_global_damage)
        self.total_min_attack = (self.total_min_attack + self.elixir_attack)
        self.total_max_attack = (self.total_max_attack + self.elixir_attack)
        self.total_armor = (self.total_armor + self.elixir_armor)
        self.total_min_spellpower = (self.total_min_spellpower + self.elixir_spellpower)
        self.total_max_spellpower = (self.total_max_spellpower + self.elixir_spellpower)
        self.total_magic_resistance = (self.total_magic_resistance + self.elixir_magic_resistance)
        self.total_min_necrosurge = (self.total_min_necrosurge + self.elixir_necrosurge)
        self.total_max_necrosurge = (self.total_max_necrosurge + self.elixir_necrosurge)
    end

    def set_default_values_for_buffed_stats
        self.buffed_min_attack = 0
        self.buffed_max_attack = 0
        self.buffed_min_spellpower = 0
        self.buffed_max_spellpower = 0
        self.buffed_armor = 0
        self.buffed_min_necrosurge = 0
        self.buffed_max_necrosurge = 0
        self.buffed_magic_resistance = 0
        self.buffed_critical_strike_chance = 0.0
        self.buffed_critical_strike_damage = 0.0
        self.buffed_damage_reduction = 0.0
        self.buffed_critical_resistance = 0
        self.buffed_fire_resistance = 0
        self.buffed_cold_resistance = 0
        self.buffed_lightning_resistance = 0
        self.buffed_poison_resistance = 0
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
        elsif self.character_class == 'nightstalker'
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
        elsif self.character_class == 'nightstalker'
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
        elsif self.character_class == 'nightstalker'
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
        when 'morvandir'
            # Modify stats for goblin race
            self.health -= 3
            self.strength -= 3
            self.intelligence -= 3
            self.agility += 2
            self.dreadmight += 5
            self.willpower -= 3
        end
    end

    # Add methods to modify attributes based on class
    def modify_attributes_based_on_class
        case character_class
        when 'warrior'
            # Modify attributes for warrior class
            self.min_attack += 5
            self.max_attack += 10
            self.min_spellpower -= 15
            self.max_spellpower -= 10
            self.min_necrosurge -= 10
            self.max_necrosurge -= 5
            self.armor += 3
            self.magic_resistance -= 3
        when 'mage'
            # Modify attributes for mage class
            self.min_attack -= 15
            self.max_attack -= 10
            self.min_spellpower += 5
            self.max_spellpower += 10
            self.min_necrosurge -= 10
            self.max_necrosurge -= 5
            self.armor -= 3
            self.magic_resistance += 3
        when 'nightstalker'
            # Modify attributes for nightstalker class
            self.min_attack += 5
            self.max_attack += 10
            self.min_spellpower -= 10
            self.max_spellpower -= 5
            self.min_necrosurge -= 10
            self.max_necrosurge -= 5
            self.armor -= 2
            self.magic_resistance -= 2
        when 'paladin'
            # Modify attributes for paladin class
            self.min_attack += 2
            self.max_attack += 5
            self.min_spellpower += 2
            self.max_spellpower += 5
            self.min_necrosurge -= 15
            self.max_necrosurge -= 10
            self.armor += 1
            self.magic_resistance += 1
        when 'deathwalker'
            # Modify attributes for deathwalker class
            self.min_attack -= 15
            self.max_attack -= 10
            self.min_spellpower -= 15
            self.max_spellpower -= 10
            self.min_necrosurge += 5
            self.max_necrosurge += 10
            self.armor -= 1
            self.magic_resistance -= 1
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
            self.strength_bonus = (self.strength * 0.5)
        else
            self.strength_bonus = (self.strength * 0.10)
        end
    end

    def calculate_intelligence_bonus
        if self.character_class == 'mage' && skills.find_by(name: 'Enlighten', unlocked: true)
            self.intelligence_bonus = (self.intelligence * 0.5)
        else
            self.intelligence_bonus = (self.intelligence * 0.10)
        end
    end

    def calculate_agility_bonus
        self.agility_bonus = (self.agility * 0.04)
    end

    def calculate_dreadmight_bonus
        self.dreadmight_bonus = (self.dreadmight * 0.04)
    end

    def calculate_luck_bonus
        self.luck * 0.03
    end

    def evasion
        if self.character_class == 'warrior' && skills.find_by(name: 'Unbridled Ferocity', unlocked: true)
            evasion = 0.0
        else
            self.agility * 0.02
        end
    end

    def ignore_pain_chance
        if self.character_class == 'warrior' && skills.find_by(name: 'Unbridled Ferocity', unlocked: true)
            ignore_pain_chance = 0.0
        else
            self.willpower * 0.02
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
            when 'nightstalker'
                # Seed nightstalker skills
                nightstalker_skills_seeder = NightstalkerSkillsSeeder.new(self)
                nightstalker_skills_seeder.seed_skills
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
        if (item.all_attributes.present? && !item.all_attributes.nil?)
            self.strength -= item.all_attributes
            self.intelligence -= item.all_attributes
            self.agility -= item.all_attributes
            self.dreadmight -= item.all_attributes
            self.luck -= item.all_attributes
            self.willpower -= item.all_attributes
        end
        if (item.all_resistances.present? && !item.all_resistances.nil?)
            self.fire_resistance -= item.all_resistances
            self.cold_resistance -= item.all_resistances
            self.lightning_resistance -= item.all_resistances
            self.poison_resistance -= item.all_resistances
        end
        self.min_attack -= item.min_attack unless item.min_attack.nil?
        self.max_attack -= item.max_attack unless item.max_attack.nil?
        self.min_necrosurge -= item.min_necrosurge unless item.min_necrosurge.nil?
        self.max_necrosurge -= item.max_necrosurge unless item.max_necrosurge.nil?
        self.health -= item.health unless item.health.nil?
        self.armor -= item.armor unless item.armor.nil?
        self.min_spellpower -= item.min_spellpower unless item.min_spellpower.nil?
        self.max_spellpower -= item.max_spellpower unless item.max_spellpower.nil?
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
        self.damage_reduction -= item.damage_reduction unless item.damage_reduction.nil?
        self.critical_resistance -= item.critical_resistance unless item.critical_resistance.nil?
        self.fire_resistance -= item.fire_resistance unless item.fire_resistance.nil?
        self.cold_resistance -= item.cold_resistance unless item.cold_resistance.nil?
        self.lightning_resistance -= item.lightning_resistance unless item.lightning_resistance.nil?
        self.poison_resistance -= item.poison_resistance unless item.poison_resistance.nil?
    end

    def modify_stats_based_on_item(item)
        # Adds stats of the equipped item
        if (item.all_attributes.present? && !item.all_attributes.nil?)
            self.strength += item.all_attributes
            self.intelligence += item.all_attributes
            self.agility += item.all_attributes
            self.dreadmight += item.all_attributes
            self.luck += item.all_attributes
            self.willpower += item.all_attributes
        end
        if (item.all_resistances.present? && !item.all_resistances.nil?)
            self.fire_resistance += item.all_resistances
            self.cold_resistance += item.all_resistances
            self.lightning_resistance += item.all_resistances
            self.poison_resistance += item.all_resistances
        end
        self.min_attack += item.min_attack unless item.min_attack.nil?
        self.max_attack += item.max_attack unless item.max_attack.nil?
        self.min_necrosurge += item.min_necrosurge unless item.min_necrosurge.nil?
        self.max_necrosurge += item.max_necrosurge unless item.max_necrosurge.nil?
        self.health += item.health unless item.health.nil?
        self.armor += item.armor unless item.armor.nil?
        self.min_spellpower += item.min_spellpower unless item.min_spellpower.nil?
        self.max_spellpower += item.max_spellpower unless item.max_spellpower.nil?
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
        self.damage_reduction += item.damage_reduction unless item.damage_reduction.nil?
        self.critical_resistance += item.critical_resistance unless item.critical_resistance.nil?
        self.fire_resistance += item.fire_resistance unless item.fire_resistance.nil?
        self.cold_resistance += item.cold_resistance unless item.cold_resistance.nil?
        self.lightning_resistance += item.lightning_resistance unless item.lightning_resistance.nil?
        self.poison_resistance += item.poison_resistance unless item.poison_resistance.nil?
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
            self.health += 14
        when 'mage'
            self.health += 10
        when 'nightstalker'
            self.health += 12
        when 'paladin'
            self.health += 16
        when 'deathwalker'
            self.health += 18
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
                update(elixir_attack: ((self.total_max_attack * 0.10) * elixir.potion_effect).round)
            when "Elixir of Power"
                update(elixir_spellpower: ((self.total_max_spellpower * 0.10) * elixir.potion_effect).round)
            when "Elixir of Decay"
                update(elixir_necrosurge: ((self.total_max_necrosurge  * 0.10) * elixir.potion_effect).round)
            when "Elixir of Fortitude"
                update(elixir_armor: (self.total_armor * elixir.potion_effect).round)
            when "Elixir of Knowledge"
                update(elixir_magic_resistance: (self.total_magic_resistance * elixir.potion_effect).round)
            end
        end
    end

    def remaining_elixir_time(item)
        return { remaining_time: 0 } unless item.present?

        expiration_time = item.elixir_applied_at.to_i + item.duration.seconds.to_i
        remaining_time = [expiration_time - Time.current.to_i, 0].max

        { remaining_time: remaining_time, expiration_time: expiration_time }
    end

    def self.expired_elixirs
        characters_with_active_elixir = Character.where(elixir_active: true)

        characters_with_active_elixir.each do |character|
            expired_elixirs = Item.where(id: character.active_elixir_ids)

            expired_elixirs.each do |elixir|
            expiration_time = elixir.elixir_applied_at + elixir.duration.seconds

                if Time.current >= expiration_time
                    # This elixir is expired, remove it
                    character.active_elixir_ids.delete(elixir.id)
                end
            end

            if character.active_elixir_ids.empty?
                character.elixir_active = false
            end

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

    def has_legendary_item_equipped?
        equipment_slots = %i[head chest hands feet main_hand off_hand finger1 finger2 neck waist]
        legendary_items_count = 0
            equipment_slots.each do |slot|
                equipped_item = self.send(slot)
                legendary_items_count += 1 if equipped_item&.rarity == 'Legendary'
            end
        legendary_items_count >= 3
    end

    def can_equip?(item)
        if self.level >= item.level_requirement
            if item.rarity == 'Legendary' && has_legendary_item_equipped?
                errors.add(:base, "You can only equip a maximum of 3 Legendary items.")
                return false
            end
                case item.item_class
                    when 'Sword'
                        # All characters can equip one-handed swords
                        return true if item.item_type == 'One-handed Weapon'
                        # For two-handed swords, restrict to warriors and paladins
                        return true if item.item_type == 'Two-handed Weapon' && %w[warrior paladin deathwalker].include?(character_class)
                        errors.add(:base, "Only Warriors, Deathwalkers and Paladins can equip Two-handed Swords.")
                        return false
                    when 'Great Shield'
                        return true if %w[paladin warrior].include?(character_class)
                        errors.add(:base, "Only Paladins and Warriors can equip Great Shields.")
                        return false
                    when 'Small Shield'
                        return true if %w[warrior paladin mage acolyte].include?(character_class)
                        errors.add(:base, "Only Warriors, Paladins, Mages and Acolytes can equip Small Shields.")
                        return false
                    when 'Axe'
                        return true if %w[warrior deathwalker].include?(character_class)
                        errors.add(:base, "Only Warriors and Deathwalkers can equip Axes.")
                        return false
                    when 'Mace'
                        return true if character_class == 'paladin'
                        errors.add(:base, "Only Paladins can equip Maces.")
                        return false
                    when 'Dagger'
                        return true if %w[nightstalker hunter mage acolyte].include?(character_class)
                        errors.add(:base, "Only Nightstalkers, Hunters, Mages and Acolytes can equip Daggers.")
                        return false
                    when 'Bow'
                        return true if character_class == 'hunter'
                        errors.add(:base, "Only Hunters can equip Bows.")
                        return false
                    when 'Staff'
                        return true if %w[mage acolyte].include?(character_class)
                        errors.add(:base, "Only Mages and Acolytes can equip Staves.")
                        return false
                    when 'Plate'
                        return true if %w[warrior paladin deathwalker].include?(character_class)
                        errors.add(:base, "Only Warriors, Paladins and Deathwalkers can equip Plate.")
                        return false
                    when 'Leather'
                        return true if %w[nightstalker hunter].include?(character_class)
                        errors.add(:base, "Only Nightstalkers and Hunters can equip leather.")
                        return false
                    when 'Cloth'
                        return true if %w[mage acolyte].include?(character_class)
                        errors.add(:base, "Only Mages and Acolytes can equip cloth.")
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

    def unequip_main_hand
        return unless self.main_hand
        # Add the two-handed weapon back to the inventory
        add_item_to_inventory(self.main_hand)
        # Modify stats based on the unequipped two-handed weapon
        revert_stats_based_on_item(self.main_hand)
        # Clear the character's main hand
        self.main_hand = nil
    end

    def unequip_off_hand
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
            self.main_hand = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        # Case 2: Main hand but no off hand
        elsif self.main_hand.present? && self.off_hand.nil?
            if self.main_hand.item_type == 'One-handed Weapon'
                if ((self.main_hand.item_class == 'Dagger' || self.main_hand.item_class == 'Sword') && (self.character_class == 'nightstalker' || self.character_class == 'hunter'))
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                    return
                elsif ((self.main_hand.item_class == 'Sword') && (self.character_class == 'nightstalker' || self.character_class == 'deathwalker'))
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                    return
                end
                unequip_main_hand
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.main_hand.item_type == 'Two-handed Weapon'
                unequip_main_hand
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
                if ((self.character_class == 'nightstalker' || self.character_class == 'hunter') && (item.item_class == 'Dagger' || item.item_class == 'Sword'))
                    self.main_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                end
                unequip_off_hand
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
            if self.off_hand.item_type == 'Shield'
                unequip_main_hand
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                if (self.main_hand.item_class == 'Dagger' || self.main_hand.item_class == 'Sword') && self.character_class == 'nightstalker'
                    unequip_off_hand
                    self.off_hand = item
                    remove_item_from_inventory(item)
                    modify_stats_based_on_item(item)
                    return
                end
                unequip_main_hand
                unequip_off_hand
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon'
                unequip_main_hand
                unequip_off_hand
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
                unequip_main_hand
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        # Case 3: Main hand and off hand
        elsif self.main_hand.present? && self.off_hand.present?
            Rails.logger.debug("################## Entering Case 3")
            if self.off_hand.item_type == 'Shield'
                unequip_off_hand
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                unequip_off_hand
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon'
                unequip_main_hand
                unequip_off_hand
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
                    unequip_main_hand
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
                    unequip_main_hand
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
                unequip_off_hand
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                # Remove the main hand and off hand then equip the item in main hand
                unequip_off_hand
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
                unequip_main_hand
                unequip_off_hand
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'One-handed Weapon'
                # Remove the main hand and off hand then equip the item
                unequip_main_hand
                unequip_off_hand
                self.main_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            elsif self.off_hand.item_type == 'Two-handed Weapon' && skills.find_by(name: 'Forged in Battle', unlocked: true)
                # Equip the item in off hand if Forged in Battle talent
                unequip_off_hand
                self.off_hand = item
                remove_item_from_inventory(item)
                modify_stats_based_on_item(item)
            end
        end
    end

    def unequip_head
        return unless self.head
        # Add the helmet back to the inventory
        add_item_to_inventory(head)
        # Modify stats based on the removed helmet
        revert_stats_based_on_item(head)
        # Clear the character's helmet
        self.head = nil
    end
    def equip_head(item)
        if self.head.nil?
            # No existing helmet
            self.head = item
            # Remove the helmet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the equipped helmet
            modify_stats_based_on_item(item)
        else
            # Replace the existing helmet
            unequip_head
            self.head = item
            # Remove the new helmet from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped helmet
            modify_stats_based_on_item(item)
        end
    end

    def unequip_chest
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
            unequip_chest
            self.chest = item
            # Remove the new chest from the inventory without deleting it
            remove_item_from_inventory(item)
            # Modify stats based on the newly equipped chest
            modify_stats_based_on_item(item)
        end
    end

    def unequip_neck
        return unless self.neck
        add_item_to_inventory(self.neck)
        revert_stats_based_on_item(self.neck)
        self.neck = nil
    end
    def equip_neck(item)
        if self.neck.nil?
            self.neck = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_neck
            self.neck = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_finger1
        return unless self.finger1
        add_item_to_inventory(self.finger1)
        revert_stats_based_on_item(self.finger1)
        self.finger1 = nil
    end
    def unequip_finger2
        return unless self.finger2
        add_item_to_inventory(self.finger2)
        revert_stats_based_on_item(self.finger2)
        self.finger2 = nil
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
            unequip_finger1
            self.finger1 = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_waist
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
            unequip_waist
            self.waist = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_hands
        return unless self.hands
        add_item_to_inventory(self.hands)
        revert_stats_based_on_item(self.hands)
        self.hands = nil
    end
    def equip_hands(item)
        if hands.nil?
            self.hands = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        else
            unequip_amulet
            self.hands = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    def unequip_feet
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
            unequip_feet
            self.feet = item
            remove_item_from_inventory(item)
            modify_stats_based_on_item(item)
        end
    end

    private

    def max_characters
        errors.add(:base, "You cannot have more than 3 characters") if user.characters.count >= 3
    end

    def valid_character_name
        unless character_name.match?(/\A[[:alpha:]äâéàè']+\z/)
            errors.add(:character_name, "is invalid <br>Please enter a new name")
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
        self.total_min_attack = [self.total_min_attack, 0].max
        self.total_max_attack = [self.total_max_attack, 0].max
        self.total_min_spellpower = [self.total_min_spellpower, 0].max
        self.total_max_spellpower = [self.total_max_spellpower, 0].max
        self.total_min_necrosurge = [self.total_min_necrosurge, 0].max
        self.total_max_necrosurge = [self.total_max_necrosurge, 0].max
    end
end
