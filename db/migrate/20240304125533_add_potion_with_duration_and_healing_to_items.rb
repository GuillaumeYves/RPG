class AddPotionWithDurationAndHealingToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :duration, :integer
    add_column :items, :potion_heal_amount, :decimal
    add_column :items, :potion_effect, :decimal

    add_column :characters, :elixir_active, :boolean, default: false
    add_column :characters, :elixir_applied_at, :datetime
    add_column :characters, :elixir_duration, :integer
    add_column :characters, :elixir_attack, :integer, default: 0
    add_column :characters, :elixir_spellpower, :integer, default: 0
    add_column :characters, :elixir_necrosurge, :integer, default: 0
    add_column :characters, :elixir_armor, :integer, default: 0
    add_column :characters, :elixir_magic_resistance, :integer, default: 0
    add_column :characters, :elixir_global_damage, :integer, default: 0
    add_column :characters, :elixir_total_health, :integer, default: 0
  end
end
