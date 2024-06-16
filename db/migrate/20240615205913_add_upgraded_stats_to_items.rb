class AddUpgradedStatsToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :upgraded_min_attack, :integer, default: 0
    add_column :items, :upgraded_max_attack, :integer, default: 0
    add_column :items, :upgraded_min_spellpower, :integer, default: 0
    add_column :items, :upgraded_max_spellpower, :integer, default: 0
    add_column :items, :upgraded_min_necrosurge, :integer, default: 0
    add_column :items, :upgraded_max_necrosurge, :integer, default: 0
    add_column :items, :upgraded_health, :integer, default: 0
    add_column :items, :upgraded_global_damage, :decimal, precision: 6, scale: 3, default: 0.00
    add_column :items, :upgraded_critical_strike_chance, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :items, :upgraded_critical_strike_damage, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :items, :upgraded_armor, :integer, default: 0
    add_column :items, :upgraded_magic_resistance, :integer, default: 0
    add_column :items, :upgraded_strength, :integer, default: 0
    add_column :items, :upgraded_intelligence, :integer, default: 0
    add_column :items, :upgraded_agility, :integer, default: 0
    add_column :items, :upgraded_dreadmight, :integer, default: 0
    add_column :items, :upgraded_luck, :integer, default: 0
    add_column :items, :upgraded_willpower, :integer, default: 0
  end
end
