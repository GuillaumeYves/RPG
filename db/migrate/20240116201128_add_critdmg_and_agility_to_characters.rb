class AddCritdmgAndAgilityToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :agility, :integer, default: 5
    add_column :characters, :critical_strike_damage, :float, default: 1.5
  end
end
