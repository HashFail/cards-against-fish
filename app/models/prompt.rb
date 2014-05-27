class Prompt < SemiactiveRecord
	attr_accessible :text, :blanks, :card_pack_id

	belongs_to :card_pack

	before_save :check

	def check
		self.blanks ||= 1
		true
	end

	def card_pack
		CardPack.find(card_pack_id)
	end

	def save
		new  = new_record?
		super
		card_pack.add_prompt(self) if new
		self
	end
end
