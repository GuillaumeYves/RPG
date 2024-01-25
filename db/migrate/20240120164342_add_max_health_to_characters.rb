class AddMaxHealthToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :max_health, :integer, default: 100
  end
end
