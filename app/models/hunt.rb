class Hunt < ApplicationRecord
    belongs_to :character, optional: true
    has_many :monsters



    def scaled_experience_reward(character_level)
        scaling_factor = case character_level
            when 1..9 then 1.0
            when 10..19 then 0.90
            when 20..39 then 0.80
            when 40..49 then 0.70
            when 50..59 then 0.60
            when 60..69 then 0.50
            when 70..79 then 0.40
            when 80..99 then 0.30
            when 100..199 then 0.20
            when 200..299 then 0.10
            when 300..Float::INFINITY then 0.05
            else 1.0
            end

        base_experience = (self.experience_reward * scaling_factor).round
        level_difference = character_level - self.level_requirement

        if level_difference <= 5
            # Character level <= Hunt level + 5: XP = (100 %)
            base_experience
        elsif level_difference.between?(6, 9)
            # Character level = Hunt level + 6 to Hunt level + 9
            scaling_percentage = (100 - (level_difference - 5) * 20) / 100.0
            (base_experience * scaling_percentage / 5).round * 5
        else
        # Character level >= Hunt level + 10: XP = (10 %)
            (base_experience * 0.1 / 5).round * 5
        end
    end








end
