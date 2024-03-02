class AddEnergyArenaTicketsDailyQuestsToCharacters < ActiveRecord::Migration[7.1]
  def change
    add_column :characters, :energy, :integer, default: 100
    add_column :characters, :max_energy, :integer, default: 100
    add_column :characters, :arena_ticket, :integer, default: 10
    add_column :characters, :max_arena_ticket, :integer, default: 10
    add_column :characters, :daily_quest, :integer, default: 10
    add_column :characters, :max_daily_quest, :integer, default: 10
  end
end
