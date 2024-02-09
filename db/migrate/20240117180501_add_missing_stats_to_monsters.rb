class AddMissingStatsToMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :monsters, :spellpower, :integer, default: 10
    add_column :monsters, :strength, :integer, default: 5
    add_column :monsters, :intelligence, :integer, default: 5
    add_column :monsters, :luck, :integer, default: 5
    add_column :monsters, :willpower, :integer, default: 5
    add_column :monsters, :agility, :integer, default: 5
    add_column :monsters, :level, :integer, default: 1
    add_column :monsters, :critical_strike_damage, :float, default: 1.2
  end
end
