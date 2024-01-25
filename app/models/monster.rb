class Monster < ApplicationRecord
    has_one_attached :monster_image
    belongs_to :hunt, optional: true

    attr_accessor :buffed_attack, :buffed_spellpower, :buffed_armor, :buffed_magic_resistance, :buffed_critical_strike_damage
    attr_accessor :took_damage
end
