class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :card_pack_id
      t.integer :user_id
      t.boolean :up

      t.timestamps
    end
  end
end
