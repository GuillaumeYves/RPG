class AddUnlocksToSkills < ActiveRecord::Migration[7.1]
  def change
    add_column :skills, :locked, :boolean, default: true
    add_column :skills, :unlocked, :boolean
  end
end
