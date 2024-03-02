class ChangeFloatsToDecimalsForPrecision < ActiveRecord::Migration[7.1]
  def change
    change_column :characters, :critical_strike_damage, :decimal, precision: 5, scale: 2, default: 1.2
    change_column :characters, :total_critical_strike_damage, :decimal, precision: 5, scale: 2
    change_column :characters, :critical_strike_chance, :decimal, precision: 5, scale: 2, default: 1.0
    change_column :characters, :total_critical_strike_chance, :decimal, precision: 5, scale: 2
    change_column :characters, :global_damage, :decimal, precision: 6, scale: 3, default: 0.0
    change_column :characters, :total_global_damage, :decimal, precision: 6, scale: 3
    change_column :characters, :paragon_critical_strike_chance, :decimal, precision: 5, scale: 2, default: 0.0
    change_column :characters, :paragon_critical_strike_damage, :decimal, precision: 5, scale: 2, default: 0.0
    change_column :characters, :paragon_global_damage, :decimal, precision: 6, scale: 3, default: 0.0
    change_column :characters, :paragon_attack, :decimal, precision: 5, scale: 2, default: 0.0
    change_column :characters, :paragon_armor, :decimal, precision: 5, scale: 2, default: 0.0
    change_column :characters, :paragon_spellpower, :decimal, precision: 5, scale: 2, default: 0.0
    change_column :characters, :paragon_magic_resistance, :decimal, precision: 5, scale: 2, default: 0.0
    change_column :characters, :paragon_total_health, :decimal, precision: 6, scale: 3, default: 0.0

    change_column :items, :critical_strike_chance, :decimal, precision: 5, scale: 2
    change_column :items, :critical_strike_damage, :decimal, precision: 5, scale: 2
    change_column :items, :global_damage, :decimal, precision: 6, scale: 3

    change_column :monsters, :critical_strike_damage, :decimal, precision: 5, scale: 2, default: 1.2
    change_column :monsters, :total_critical_strike_damage, :decimal, precision: 5, scale: 2
    change_column :monsters, :critical_strike_chance, :decimal, precision: 5, scale: 2, default: 1.0
    change_column :monsters, :total_critical_strike_chance, :decimal, precision: 5, scale: 2
  end
end
