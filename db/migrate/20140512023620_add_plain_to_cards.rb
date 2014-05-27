class AddPlainToCards < ActiveRecord::Migration
  def change
  	add_column :cards, :plain, :boolean, :default => false
  end
end
