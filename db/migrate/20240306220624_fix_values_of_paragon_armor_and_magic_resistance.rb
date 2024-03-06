class FixValuesOfParagonArmorAndMagicResistance < ActiveRecord::Migration[7.1]
  def change
    change_column :characters, :paragon_armor, :decimal, precision: 6, scale: 3, default: 0.0
    change_column :characters, :paragon_magic_resistance, :decimal, precision: 6, scale: 3, default: 0.0
  end
end
