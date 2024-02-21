class AddTotalHealthToCharactersAndMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :monsters, :total_health, :integer
    add_column :monsters, :total_max_health, :integer
    add_column :characters, :total_health, :integer
    add_column :characters, :total_max_health, :integer
  end
end
