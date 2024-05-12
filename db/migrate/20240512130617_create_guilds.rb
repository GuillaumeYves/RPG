class CreateGuilds < ActiveRecord::Migration[7.1]
  def change
    create_table :guilds do |t|
      t.string :name
      t.integer :leader_id
      t.integer :membership_status

      t.timestamps
    end
  end
end
