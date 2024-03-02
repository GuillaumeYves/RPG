class AddParagonPointsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :paragon_points, :integer, default: 0
  end
end
