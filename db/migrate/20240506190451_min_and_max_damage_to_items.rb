class MinAndMaxDamageToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :min_attack, :integer
    add_column :items, :max_attack, :integer
    add_column :items, :min_spellpower, :integer
    add_column :items, :max_spellpower, :integer
    add_column :items, :min_necrosurge, :integer
    add_column :items, :max_necrosurge, :integer
  end
end
