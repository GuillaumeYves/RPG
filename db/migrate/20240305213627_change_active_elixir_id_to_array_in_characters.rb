class ChangeActiveElixirIdToArrayInCharacters < ActiveRecord::Migration[7.1]
  def change
    remove_column :characters, :active_elixir_id
    add_column :characters, :active_elixir_ids, :bigint, array: true, default: []
  end
end
