class AddMonsterImagetoMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :monsters, :monster_image, :string
  end
end
