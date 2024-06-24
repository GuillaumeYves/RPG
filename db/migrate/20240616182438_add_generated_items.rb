class AddGeneratedItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :generated_item, :boolean, default: false
  end
end
