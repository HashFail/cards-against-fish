class Card < SemiactiveRecord
	attr_accessible :before, :after, :word, :word_type, :card_pack_id, :plain

	VERB = 0
	NOUN = 1
	ADJECTIVE = 2

	class BlankCard
		@next_id = 1

		def blank?
			return true
		end

		def id
			@id
		end

		def initialize
			@id = "blank" + self.class.next_id.to_s
			self.class.increment_id
		end

		def plain
			false
		end

		def print(params = {})
			params[:text] || "_____"
		end

		def adjective?
			false
		end

		def noun?
			false
		end

		def verb?
			false
		end

		protected

		def self.next_id
			@next_id
		end

		def self.increment_id
			@next_id += 1
		end
	end

	before_save :check_attributes
	before_save :normalize

	belongs_to :card_pack

	def card_pack
		CardPack.find(card_pack_id)
	end

	def self.blank
		return BlankCard.new
	end

	def blank?
		return false
	end

	def verb?
		word_type == 0
	end

	def noun?
		word_type == 1
	end

	def adjective?
		word_type == 2
	end

	def print(params = {})
		if plain || word_type == ADJECTIVE || word_type == NOUN && params[:plurality] != "plural"
			return before.to_s + word + after.to_s
		end
		if word_type == VERB
			params[:tense] ||= :present
			params[:person] ||= :first
			return before.to_s + word.en.conjugate(params[:tense].to_sym, params[:person].to_sym) + after.to_s
		end 
		return before.to_s + word.en.plural + after.to_s
	end

	def save	
		new = new_record?
		super
		self.card_pack.add_card(self) if new
		self
	end

	private

	def check_attributes
		v = true
		unless (0..2).include?(self.word_type)
			self.errors.add(:type, "Invalid word.")
			v = false
		end
		if self.word.nil?
			self.errors.add(:name, "Word can't be blank.")
			v = false
		end
		if self.card_pack_id.nil?
			self.errors.add(:card_pack_id, "Card pack can't be empty")
			v = false
		end
		return v
	end

	def normalize
		self.word = self.word.strip if self.word
		self.before = self.before.strip if self.before
		self.after = self.after.strip if self.after
		unless self.before.nil? || self.before.empty?
			self.before = self.before + " "
		end
		unless self.after.nil? || self.after.empty?
			self.after = " " + self.after
		end
		if plain
			self.word = before.to_s + word + after.to_s
			self.before = nil
			self.after = nil
		end
	end
end
