class AddTotalStatsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :total_attack, :integer
    add_column :characters, :total_spellpower, :integer
    add_column :characters, :total_armor, :integer
    add_column :characters, :total_magic_resistance, :integer
    add_column :characters, :total_critical_strike_damage, :float
  end
end
