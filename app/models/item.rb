class Item < ApplicationRecord
    belongs_to :character, optional: true
    belongs_to :inventory, optional: true, polymorphic: true

    has_one_attached :item_image
end