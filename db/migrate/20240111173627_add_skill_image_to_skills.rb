class AddSkillImageToSkills < ActiveRecord::Migration[7.1]
  def change
    add_column :skills, :skill_image, :string
  end
end
