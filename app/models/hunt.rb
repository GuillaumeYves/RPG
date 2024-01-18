class Hunt < ApplicationRecord
    belongs_to :character, optional: true
    belongs_to :monster
end
