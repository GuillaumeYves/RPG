class AddGlobalDamageToMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :monsters, :global_damage, :decimal, precision: 6, scale: 3, default: 0.0
    add_column :monsters, :total_global_damage, :decimal, precision: 6, scale: 3
  end
end
