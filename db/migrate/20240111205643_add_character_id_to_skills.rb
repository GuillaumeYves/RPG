class AddCharacterIdToSkills < ActiveRecord::Migration[7.1]
  def change
    add_reference :skills, :character, foreign_key: true
  end
end
