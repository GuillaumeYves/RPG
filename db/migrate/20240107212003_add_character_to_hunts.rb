class AddCharacterToHunts < ActiveRecord::Migration[7.1]
  def change
    add_reference :hunts, :character, foreign_key: true
  end
end
