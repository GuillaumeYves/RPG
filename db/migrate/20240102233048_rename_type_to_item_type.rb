class RenameTypeToItemType < ActiveRecord::Migration[7.1]
  def change
    rename_column :items, :type, :item_type
  end
end
