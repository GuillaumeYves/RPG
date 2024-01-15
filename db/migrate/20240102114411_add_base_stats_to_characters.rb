class AddBaseStatsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :health, :integer, default: 100
    add_column :characters, :attack, :integer, default: 10
    add_column :characters, :armor, :integer, default: 5
    add_column :characters, :spellpower, :integer, default: 10
    add_column :characters, :magic_resistance, :integer, default: 5
    add_column :characters, :strength, :integer, default: 5
    add_column :characters, :intelligence, :integer, default: 5
    add_column :characters, :luck, :integer, default: 5
    add_column :characters, :willpower, :integer, default: 5
  end
end
