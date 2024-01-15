class CreateMonsters < ActiveRecord::Migration[7.1]
  def change
    create_table :monsters do |t|
      t.string "monster_name"
      t.integer "health", default: 100
      t.integer "attack", default: 10
      t.integer "armor", default: 5
      t.integer "magic_resistance", default: 5

      t.timestamps
    end
  end
end
