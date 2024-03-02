class AddGearSlotsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :main_hand, :bigint
    add_column :characters, :off_hand, :bigint
    add_column :characters, :head, :bigint
    add_column :characters, :chest, :bigint
    add_column :characters, :legs, :bigint
    add_column :characters, :neck, :bigint
    add_column :characters, :finger1, :bigint
    add_column :characters, :finger2, :bigint
    add_column :characters, :waist, :bigint
    add_column :characters, :hands, :bigint
    add_column :characters, :feet, :bigint
    add_foreign_key :characters, :items, column: :main_hand
    add_foreign_key :characters, :items, column: :off_hand
    add_foreign_key :characters, :items, column: :head
    add_foreign_key :characters, :items, column: :chest
    add_foreign_key :characters, :items, column: :legs
    add_foreign_key :characters, :items, column: :neck
    add_foreign_key :characters, :items, column: :finger1
    add_foreign_key :characters, :items, column: :finger2
    add_foreign_key :characters, :items, column: :waist
    add_foreign_key :characters, :items, column: :hands
    add_foreign_key :characters, :items, column: :feet
  end
end
