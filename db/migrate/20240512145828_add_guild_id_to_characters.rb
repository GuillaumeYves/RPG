class AddGuildIdToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_reference :characters, :guild, foreign_key: true
  end
end
