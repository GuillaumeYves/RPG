class FixCharactersBlockChance < ActiveRecord::Migration[7.1]
  def change
    change_column :characters, :block_chance, :integer, default: "0"
  end
end
