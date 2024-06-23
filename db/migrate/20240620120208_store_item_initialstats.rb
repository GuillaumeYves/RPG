class StoreItemInitialstats < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :initial_min_attack, :integer, default: 0
    add_column :items, :initial_max_attack, :integer, default: 0
    add_column :items, :initial_min_spellpower, :integer, default: 0
    add_column :items, :initial_max_spellpower, :integer, default: 0
    add_column :items, :initial_min_necrosurge, :integer, default: 0
    add_column :items, :initial_max_necrosurge, :integer, default: 0
    add_column :items, :initial_health, :integer, default: 0
    add_column :items, :initial_global_damage, :decimal, precision: 6, scale: 3, default: 0.00
    add_column :items, :initial_critical_strike_chance, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :items, :initial_critical_strike_damage, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :items, :initial_armor, :integer, default: 0
    add_column :items, :initial_magic_resistance, :integer, default: 0
    add_column :items, :initial_strength, :integer, default: 0
    add_column :items, :initial_intelligence, :integer, default: 0
    add_column :items, :initial_agility, :integer, default: 0
    add_column :items, :initial_dreadmight, :integer, default: 0
    add_column :items, :initial_luck, :integer, default: 0
    add_column :items, :initial_willpower, :integer, default: 0
  end
end
