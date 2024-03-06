class FixElixirUpdates < ActiveRecord::Migration[7.1]
  def change
    remove_column :characters, :elixir_duration
    remove_column :characters, :elixir_applied_at

    add_column :items, :elixir_applied_at, :datetime
  end
end
