class ChangeRaceColumnToString < ActiveRecord::Migration[7.1]
  def change
    change_column :characters, :race, :string
  end
end
