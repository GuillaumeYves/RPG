class AddBlockChanceToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :block_chance, :integer
    add_column :items, :upgraded_block_chance, :integer
    add_column :items, :initial_block_chance, :integer

    add_column :characters, :block_chance, :integer
    add_column :characters, :total_block_chance, :integer
  end
end
