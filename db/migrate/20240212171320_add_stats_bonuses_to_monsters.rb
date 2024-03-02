class AddStatsBonusesToMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :monsters, :strength_bonus,:integer, default: 0
    add_column :monsters, :intelligence_bonus,:integer, default: 0
    add_column :monsters, :agility_bonus,:integer, default: 0
  end
end
