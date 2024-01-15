class AddLevelAndExperienceToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :level, :integer, default: 1
    add_column :characters, :experience, :integer, default: 0
  end
end
