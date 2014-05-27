class Vote < ActiveRecord::Base
	attr_accessible :card_pack_id, :up

	belongs_to :card_packs
	belongs_to :user
end
