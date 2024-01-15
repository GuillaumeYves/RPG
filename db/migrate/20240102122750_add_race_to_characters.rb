class AddRaceToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :race, :integer
  end
end
