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
  end
end
