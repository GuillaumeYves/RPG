class AddArenaRankToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :arena_rank, :integer, default: 0
  end
end
