class AddEnergyCostToHunts < ActiveRecord::Migration[7.1]
  def change
    add_column :hunts, :energy_cost, :integer
  end
end
