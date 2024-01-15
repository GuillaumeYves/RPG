class AddSkillPointsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :skill_points, :integer, default: 0
  end
end
