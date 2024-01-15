class AddCharacterNameToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :character_name, :string
  end
end
