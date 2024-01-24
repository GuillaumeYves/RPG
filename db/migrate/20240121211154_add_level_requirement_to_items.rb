class AddLevelRequirementToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :level_requirement, :integer
  end
end
