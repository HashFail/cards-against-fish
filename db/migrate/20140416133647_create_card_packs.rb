class CreateCardPacks < ActiveRecord::Migration
  def change
    create_table :card_packs do |t|
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
