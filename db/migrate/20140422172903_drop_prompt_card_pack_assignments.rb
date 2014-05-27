class DropPromptCardPackAssignments < ActiveRecord::Migration
  def change
  	drop_table :prompt_card_pack_assignments
	add_column :prompts, :card_pack_id, :integer
  end
end
