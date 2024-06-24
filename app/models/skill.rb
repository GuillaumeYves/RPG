class Skill < ApplicationRecord
  belongs_to :character
  has_one_attached :skill_image
  enum character_class: { warrior: 'warrior', mage: 'mage', nightstalker: 'nightstalker', paladin: 'paladin', deathwalker: 'deathwalker' }
end
