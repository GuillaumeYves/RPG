class AddInventoryToItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :items, :inventory, polymorphic: true
  end
end
