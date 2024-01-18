class Monster < ApplicationRecord
    has_one_attached :monster_image
    belongs_to :hunt, optional: true
    before_save :monster_modify_stats_based_on_attributes

    def monster_modify_stats_based_on_attributes
        self.attack += monster_strength_bonus
        self.spellpower += monster_intelligence_bonus
        critical_strike_chance
        evasion
        ignore_pain_chance
    end

    def monster_strength_bonus
        self.strength * 0.04
    end

    def monster_intelligence_bonus
        self.intelligence * 0.04
    end

    def critical_strike_chance
        self.luck * 0.05
    end

    def evasion
        self.agility * 0.03
    end

    def ignore_pain_chance
        self.willpower * 0.03
    end
end
