class AddExpForNextLevelToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :required_experience_for_next_level, :integer, default: 500
  end
end
