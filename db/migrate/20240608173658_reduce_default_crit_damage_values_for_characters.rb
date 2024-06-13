class ReduceDefaultCritDamageValuesForCharacters < ActiveRecord::Migration[7.1]
  def change
    change_column :characters, :critical_strike_damage, :decimal, precision: 5, scale: 2, default: "0.1"
  end
end
