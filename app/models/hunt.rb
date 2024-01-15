class Hunt < ApplicationRecord
    belongs_to :character, optional: true
end
