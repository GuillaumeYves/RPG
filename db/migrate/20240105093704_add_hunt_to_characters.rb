class AddHuntToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_reference :characters, :hunt, foreign_key: true
  end
end
