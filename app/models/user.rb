class User < ActiveRecord::Base
	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable

	attr_accessible :username, :password, :password_confirmation, :remember_me
	has_many :card_packs
	has_many :votes

	attr_accessor :cards
	attr_accessor :score
	attr_accessor :pass
	attr_accessor :selected_cards
	attr_accessor :thread

	def has_blank?
		cards.each do |c|
			return true if c.blank?
		end
		return false
	end

	def ready?
		pass || selected_cards.count > 0
	end

	def select_cards(card_selections, number_required)
		card_selections.each do |k, v|
			i = cards.index{|c| c.id.to_s == k.to_s}
			if i
				selected_cards.push(CardSelection.new(:card=>cards[i], :params=>v))
				cards.delete_at(i)
			else
				selected_cards.each do |sc|
					cards.push(sc.card)
				end
				selected_cards = []
				return false
			end
		end
		unless selected_cards.count == number_required
			selected_cards.each do |sc|
				cards.push(sc.card)
			end
			selected_cards = []
			return false
		end
		return true
	end

	def end_turn
		@pass = false
		cards.each
		selected_cards
	end

	def initialize_for_game
		@score = 0
		@cards = []
		@pass = false
		@selected_cards = []
	end

	def has_card?(card)
		return cards.include?(card)
	end

	def has_card_type?(type)
		bool = false
		cards.each{ |c| break bool = true if c.type == type }
		return bool
	end
end
