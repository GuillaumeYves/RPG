class AddStatBonusesToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :strength_bonus,:integer, default: 0
    add_column :characters, :intelligence_bonus,:integer, default: 0
    add_column :characters, :agility_bonus,:integer, default: 0
  end
end
