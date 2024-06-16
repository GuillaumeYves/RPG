class Guild < ApplicationRecord
  MAX_MEMBERS = 30

  belongs_to :leader, class_name: 'Character'
  has_many :members, class_name: 'Character'

  validates :name, presence: true, uniqueness: true
  validate :validate_max_members

  enum membership_status: { open: 0, invite_only: 1 }

  def validate_max_members
    if members.size >= MAX_MEMBERS
      errors.add(:base, "You cannot have more guild members")
    end
  end
end
