class CardPack < SemiactiveRecord
	attr_accessible :name

	belongs_to :user
	has_many :votes

	def add_card(card)
		cards.push(card)
	end

	def add_prompt(prompt)
		prompts.push(prompt)
	end

	def cards
		@cards ||= Card.where(:card_pack_id => id)
	end

	def prompts
		@prompts ||= Prompt.where(:card_pack_id => id)
	end

	def get_random_prompt
		prompts[rand(prompts.count).to_i]
	end

	def get_random_card
		cards[rand(cards.count).to_i]
	end

	def votes
		@votes ||= Vote.where(:card_pack_id => id)
	end

	def up_vote_count
		@up_vote_count ||= votes.count{|v| v.up}
	end

	def down_vote_count
		@down_vote_count ||= votes.count{|v| !v.up}
	end

	def popularity
		up_vote_count * 100.0 / votes.count
	end
end
