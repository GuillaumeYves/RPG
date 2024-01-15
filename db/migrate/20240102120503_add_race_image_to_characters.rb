class AddRaceImageToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :race_image, :string
  end
end
