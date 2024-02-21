class AddGoldToCharactersandHunts < ActiveRecord::Migration[7.1]
  def change
    add_column :hunts, :gold_reward, :integer
    add_column :items, :gold_price, :integer
    add_column :characters, :gold, :integer, default: 0
  end
end
