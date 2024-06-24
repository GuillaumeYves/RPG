class StoreInitialValuesForNewStats < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :initial_all_attributes, :integer, default: 0
    add_column :items, :initial_all_resistances, :integer, default: 0
    add_column :items, :initial_fire_resistance, :integer, default: 0
    add_column :items, :initial_cold_resistance, :integer, default: 0
    add_column :items, :initial_lightning_resistance, :integer, default: 0
    add_column :items, :initial_poison_resistance, :integer, default: 0
    add_column :items, :initial_critical_resistance, :integer, default: 0
    add_column :items, :initial_damage_reduction, :decimal, precision: 6, scale: 3, default: 0.00
  end
end
