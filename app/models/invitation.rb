class Invitation < ApplicationRecord
  belongs_to :guild
  belongs_to :invited_character, class_name: 'Character'
  belongs_to :inviting_character, class_name: 'Character'

  enum status: { pending: 0, accepted: 1, rejected: 2 }
end
