class SeedDefaultPack < ActiveRecord::Migration
  def change
    id = CardPack.create(:name=>"Standard").id
    Card.create(:word=>"Being on fire", :word_type => 0, :card_pack_id => id, :plain => true)
    Card.create(:word=>"Women in yogur commercials", :word_type => 1, :card_pack_id => id, :plain => true)
    Card.create(:word=>"Racism", :word_type => 1, :card_pack_id => id, :plain => true)
    Card.create(:word=>"Old-people smell", :word_type => 1, :card_pack_id => id, :plain => true)
    Card.create(:word=>"A micropenis", :word_type => 1, :card_pack_id => id, :plain => true)
    Card.create(:word=>"Classist undertones", :word_type => 1, :card_pack_id => id, :plain => true)
    Card.create(:word=>"Not giving a shit about the third world", :word_type => 0, :card_pack_id => id, :plain => true)
    Card.create(:word=>"Sext", :word_type => 0, :card_pack_id => id)
    Card.create(:word=>"Roofie", :word_type => 1, :card_pack_id => id)
    Card.create(:word=>"A windmill full of corpses", :word_type => 1, :card_pack_id => id, :plain => true)
  end
end
