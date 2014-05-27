class AddCardPackIdToCards < ActiveRecord::Migration
  def change
  	add_column :cards, :card_pack_id, :integer
  end
end
