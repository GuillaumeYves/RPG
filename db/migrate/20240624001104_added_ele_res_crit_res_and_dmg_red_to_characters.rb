class AddedEleResCritResAndDmgRedToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :fire_resistance, :integer, default: 0
    add_column :characters, :cold_resistance, :integer, default: 0
    add_column :characters, :lightning_resistance, :integer, default: 0
    add_column :characters, :poison_resistance, :integer, default: 0
    add_column :characters, :critical_resistance, :integer, default: 0
    add_column :characters, :damage_reduction, :decimal, precision: 6, scale: 3, default: 0.0
    add_column :characters, :total_fire_resistance, :integer
    add_column :characters, :total_cold_resistance, :integer
    add_column :characters, :total_lightning_resistance, :integer
    add_column :characters, :total_poison_resistance, :integer
    add_column :characters, :total_critical_resistance, :integer
    add_column :characters, :total_damage_reduction, :decimal, precision: 6, scale: 3
    add_column :items, :fire_resistance, :integer
    add_column :items, :cold_resistance, :integer
    add_column :items, :lightning_resistance, :integer
    add_column :items, :poison_resistance, :integer
    add_column :items, :critical_resistance, :integer
    add_column :items, :damage_reduction, :decimal
  end
end
