class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :before
      t.string :after
      t.string :word, :null => false
      t.integer :type

      t.timestamps
    end
  end
end
