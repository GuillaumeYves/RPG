class AddTotalStatsToMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :monsters, :max_health, :integer, default: 100
    add_column :monsters, :total_attack, :integer
    add_column :monsters, :total_spellpower, :integer
    add_column :monsters, :total_armor, :integer
    add_column :monsters, :total_magic_resistance, :integer
    add_column :monsters, :critical_strike_chance, :float, default: 1.0
    add_column :monsters, :total_critical_strike_chance, :float
    add_column :monsters, :total_critical_strike_damage, :float

    add_column :characters, :critical_strike_chance, :float, default: 1.0
    add_column :characters, :total_critical_strike_chance, :float
    remove_column :characters, :selected_skills
    remove_column :characters, :selected_skill_row_1
    remove_column :characters, :selected_skill_row_2
    remove_column :characters, :selected_skill_row_3
    remove_column :characters, :selected_skill_row_4
  end
end
