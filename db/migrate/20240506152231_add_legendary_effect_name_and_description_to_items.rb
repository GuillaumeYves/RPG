class AddLegendaryEffectNameAndDescriptionToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :legendary_effect_name, :string
    add_column :items, :legendary_effect_description, :string
  end
end
