class CreateCombatResults < ActiveRecord::Migration[7.1]
  def change
    create_table :combat_results do |t|
      t.bigint :character_id
      t.bigint :opponent_id
      t.string :opponent_type
      t.text :combat_logs, array: true, default: []
      t.string :result
      t.integer :opponent_health_in_combat

      t.timestamps
    end
  end
end
