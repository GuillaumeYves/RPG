class AddNecrosurgeToCharactersAndMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :necrosurge, :integer, default: 10
    add_column :characters, :total_necrosurge, :integer
    add_column :characters, :dreadmight, :integer, default: 5
    add_column :characters, :dreadmight_bonus, :integer, default: 0
    add_column :monsters, :necrosurge, :integer, default: 10
    add_column :monsters, :total_necrosurge, :integer
    add_column :monsters, :dreadmight, :integer, default: 5
    add_column :monsters, :dreadmight_bonus, :integer, default: 0
    add_column :items, :necrosurge, :integer
    add_column :items, :dreadmight, :integer
  end
end
