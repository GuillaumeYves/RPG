class AddCritStatsToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :critical_strike_chance, :float
    add_column :items, :critical_strike_damage, :float
    add_column :items, :agility, :integer
  end
end
