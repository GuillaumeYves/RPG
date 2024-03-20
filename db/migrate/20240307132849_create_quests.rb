class CreateQuests < ActiveRecord::Migration[7.1]
  def change
    create_table :quests do |t|
      t.string :quest_type
      t.integer :quest_monster_objective
      t.integer :quest_objective
      t.integer :experience_reward
      t.integer :gold_reward
      t.integer :level_requirement
      t.text :description
      t.string :name
      t.bigint :character_id
      t.timestamps
    end
  end
end
