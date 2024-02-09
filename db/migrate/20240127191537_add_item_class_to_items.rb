class AddItemClassToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :item_class, :string
    add_column :items, :upgrade, :integer, default: 0
  end
end
