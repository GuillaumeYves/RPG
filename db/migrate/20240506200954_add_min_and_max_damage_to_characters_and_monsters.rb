class AddMinAndMaxDamageToCharactersAndMonsters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :min_attack, :integer, default: 20
    add_column :characters, :max_attack, :integer, default: 20
    add_column :characters, :min_spellpower, :integer, default: 20
    add_column :characters, :max_spellpower, :integer, default: 20
    add_column :characters, :min_necrosurge, :integer, default: 20
    add_column :characters, :max_necrosurge, :integer, default: 20
    add_column :characters, :total_min_attack, :integer
    add_column :characters, :total_max_attack, :integer
    add_column :characters, :total_min_spellpower, :integer
    add_column :characters, :total_max_spellpower, :integer
    add_column :characters, :total_min_necrosurge, :integer
    add_column :characters, :total_max_necrosurge, :integer
    add_column :monsters, :min_attack, :integer, default: 20
    add_column :monsters, :max_attack, :integer, default: 20
    add_column :monsters, :min_spellpower, :integer, default: 20
    add_column :monsters, :max_spellpower, :integer, default: 20
    add_column :monsters, :min_necrosurge, :integer, default: 20
    add_column :monsters, :max_necrosurge, :integer, default: 20
    add_column :monsters, :total_min_attack, :integer
    add_column :monsters, :total_max_attack, :integer
    add_column :monsters, :total_min_spellpower, :integer
    add_column :monsters, :total_max_spellpower, :integer
    add_column :monsters, :total_min_necrosurge, :integer
    add_column :monsters, :total_max_necrosurge, :integer
  end
end
