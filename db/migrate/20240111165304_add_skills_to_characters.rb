class AddSkillsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :selected_skills, :text, default: ""
  end
end
