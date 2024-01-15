class AddClassToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :character_class, :string
  end
end
