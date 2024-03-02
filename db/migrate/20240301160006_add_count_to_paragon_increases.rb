class AddCountToParagonIncreases < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :global_damage, :float, default: 0.0
    add_column :characters, :total_global_damage, :float

    add_column :characters, :paragon_increase_attack_count, :integer, default: 0
    add_column :characters, :paragon_increase_armor_count, :integer, default: 0
    add_column :characters, :paragon_increase_spellpower_count, :integer, default: 0
    add_column :characters, :paragon_increase_magic_resistance_count, :integer, default: 0
    add_column :characters, :paragon_increase_critical_strike_chance_count, :integer, default: 0
    add_column :characters, :paragon_increase_critical_strike_damage_count, :integer, default: 0
    add_column :characters, :paragon_increase_total_health_count, :integer, default: 0
    add_column :characters, :paragon_increase_global_damage_count, :integer, default: 0

    add_column :characters, :paragon_attack, :integer, default: 0
    add_column :characters, :paragon_armor, :integer, default: 0
    add_column :characters, :paragon_spellpower, :integer, default: 0
    add_column :characters, :paragon_magic_resistance, :integer, default: 0
    add_column :characters, :paragon_critical_strike_chance, :float, default: 0.0
    add_column :characters, :paragon_critical_strike_damage, :float, default: 0.0
    add_column :characters, :paragon_total_health, :integer, default: 0
    add_column :characters, :paragon_global_damage, :float, default: 0.0

    add_column :items, :global_damage, :float
  end
end
