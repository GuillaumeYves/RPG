class CreateInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :invitations do |t|
      t.references :guild, null: false, foreign_key: true
      t.references :invited_character, null: false, foreign_key: { to_table: :characters }
      t.references :inviting_character, null: false, foreign_key: { to_table: :characters }
      t.integer :status

      t.timestamps
    end
  end
end
