class AddDescriptionToHunt < ActiveRecord::Migration[7.1]
  def change
    add_column :hunts, :description, :text
  end
end
