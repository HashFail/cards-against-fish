class CreatePromptCardPackAssignments < ActiveRecord::Migration
  def change
    create_table :prompt_card_pack_assignments do |t|
      t.integer :card_pack_id
      t.integer :prompt_id

      t.timestamps
    end
  end
end
