class Hunt < ApplicationRecord
    belongs_to :character, optional: true
    has_many :monsters
end
