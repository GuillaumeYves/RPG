class AddEffectToSkills < ActiveRecord::Migration[7.1]
  def change
    add_column :skills, :effect, :string
  end
end
