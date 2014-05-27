class CreateCardCardPackAssignments < ActiveRecord::Migration
  def change
    create_table :card_card_pack_assignments do |t|
      t.integer :card_id
      t.integer :card_pack_id

      t.timestamps
    end
  end
end
