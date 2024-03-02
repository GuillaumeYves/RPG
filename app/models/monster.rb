class Monster < ApplicationRecord
    has_one_attached :monster_image
    belongs_to :hunt, optional: true

    after_create :set_default_values_for_buffed_stats
    after_create :set_default_values_for_total_stats
    after_create :set_default_values_for_stat_bonuses
    after_create :modify_stats_based_on_attributes


    attr_accessor :buffed_attack, :buffed_spellpower, :buffed_necrosurge, :buffed_armor, :buffed_magic_resistance, :buffed_critical_strike_chance, :buffed_critical_strike_damage
    attr_accessor :took_damage
    attr_accessor :temp_health

    def calculate_strength_bonus
        self.strength_bonus = (self.strength * 0.2)
    end

    def calculate_intelligence_bonus
        self.intelligence_bonus = (self.intelligence * 0.2)
    end

    def calculate_agility_bonus
        self.agility_bonus = (self.agility * 0.2)
    end

    def calculate_dreadmight_bonus
        self.dreadmight_bonus = (self.dreadmight * 0.2)
    end

    def calculate_luck_bonus
        self.luck * 0.05
    end

    def evasion
        self.agility * 0.03
    end

    def ignore_pain_chance
        self.willpower * 0.03
    end

    def set_default_values_for_stat_bonuses
        self.strength_bonus = 0
        self.intelligence_bonus = 0
        self.agility_bonus = 0
        self.dreadmight_bonus = 0
        save
    end

    def set_default_values_for_total_stats
        self.total_attack = self.attack + self.strength_bonus
        self.total_spellpower = self.spellpower + self.intelligence_bonus
        self.total_necrosurge = self.necrosurge + self.dreadmight_bonus
        self.total_armor = self.armor
        self.total_magic_resistance = self.magic_resistance
        self.total_critical_strike_chance = (self.critical_strike_chance + calculate_luck_bonus).round(2)
        self.total_critical_strike_damage = self.critical_strike_damage.round(2)
        self.max_health = self.health
        self.total_health = self.health
        self.total_max_health = self.total_health
        self.total_global_damage = self.global_damage
        save
    end

    def set_default_values_for_buffed_stats
        self.buffed_attack = 0
        self.buffed_spellpower = 0
        self.buffed_necrosurge = 0
        self.buffed_armor = 0
        self.buffed_magic_resistance = 0
        self.buffed_critical_strike_chance = 0.0
        self.buffed_critical_strike_damage = 0.0
    end

    def modify_stats_based_on_attributes
        calculate_strength_bonus
        calculate_intelligence_bonus
        calculate_agility_bonus
        calculate_dreadmight_bonus
        calculate_luck_bonus
        evasion
        ignore_pain_chance
        save
    end

end
