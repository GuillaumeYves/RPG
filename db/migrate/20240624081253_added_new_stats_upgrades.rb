class AddedNewStatsUpgrades < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :upgraded_all_attributes, :integer, default: 0
    add_column :items, :upgraded_all_resistances, :integer, default: 0
    add_column :items, :upgraded_fire_resistance, :integer, default: 0
    add_column :items, :upgraded_cold_resistance, :integer, default: 0
    add_column :items, :upgraded_lightning_resistance, :integer, default: 0
    add_column :items, :upgraded_poison_resistance, :integer, default: 0
    add_column :items, :upgraded_critical_resistance, :integer, default: 0
    add_column :items, :upgraded_damage_reduction, :decimal, precision: 6, scale: 3, default: 0.00
  end
end
