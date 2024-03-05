class AddActiveElixirNameToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :active_elixir_id, :bigint
  end
end
