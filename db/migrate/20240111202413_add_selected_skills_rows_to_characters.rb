class AddSelectedSkillsRowsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :selected_skill_row_1, :integer
    add_column :characters, :selected_skill_row_2, :integer
    add_column :characters, :selected_skill_row_3, :integer
    add_column :characters, :selected_skill_row_4, :integer
  end
end
