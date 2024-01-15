class AddItemImageToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :item_image, :string
  end
end
