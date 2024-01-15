class CreateHunts < ActiveRecord::Migration[7.1]
  def change
    create_table :hunts do |t|
      t.string :name
      t.integer :experience_reward
      t.integer :level_requirement
      t.integer :hunt_difficulty
      t.integer :monster_id

      t.timestamps
    end
  end
end
