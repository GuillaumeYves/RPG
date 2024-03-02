class AddCombatResultToHunts < ActiveRecord::Migration[7.1]
  def change
    add_reference :hunts, :combat_result, foreign_key: true
  end
end
