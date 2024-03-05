class CreateItems < ActiveRecord::Migration[7.1]
  def change
      create_table :items do |t|

      t.integer :strength
      t.integer :intelligence
      t.integer :luck
      t.integer :willpower
      t.integer :health
      t.integer :attack
      t.integer :armor
      t.integer :spellpower
      t.integer :magic_resistance
      t.string :name, null: false
      t.text :description
      t.string :type, null: false
      t.string :rarity
      t.integer :character_id
      t.integer :inventory_slot

      t.timestamps
    end
  end
end
