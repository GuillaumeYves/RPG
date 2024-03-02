class CombatResult < ApplicationRecord
  belongs_to :character, class_name: 'Character', foreign_key: 'character_id'
  belongs_to :opponent, polymorphic: true
end
