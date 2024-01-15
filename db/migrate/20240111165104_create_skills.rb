class CreateSkills < ActiveRecord::Migration[7.1]
  def change
    create_table :skills do |t|
      t.string :name
      t.text :description
      t.integer :row
      t.integer :level_requirement
      t.string :character_class

      t.timestamps
    end
  end
end
