class CreatePrompts < ActiveRecord::Migration
  def change
    create_table :prompts do |t|
      t.string :text
      t.integer :blanks

      t.timestamps
    end
  end
end
