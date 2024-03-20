class Quest < ApplicationRecord
  belongs_to :character, optional: true

  validates :name, presence: true
  validates :description, presence: true
  validates :experience_reward, presence: true
  validates :gold_reward, presence: true
end
