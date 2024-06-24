class AddedNewAttributesToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :all_attributes, :integer
    add_column :items, :all_resistances, :integer
  end
end
