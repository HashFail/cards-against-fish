class RenameCardType < ActiveRecord::Migration
  def change
  	rename_column :cards, :type, :word_type
  end
end
