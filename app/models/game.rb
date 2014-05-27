class Game
	def self.find_by_name(name)
		game = nil
		games.each{|g| break game = g if g.name == name }
		return game 
	end

	def self.delete(game)
		g = games.delete(game)
		if g
			PrivatePub.publish_to g.url, :method => "gameEnded"
		end
	end

	def self.games
		return @games ||= GAMES
	end

	attr_accessor :password
	attr_accessor :max_players
	attr_accessor :name
	attr_accessor :players
	attr_accessor :creator
	attr_accessor :current_player
	attr_accessor :card_packs
	attr_accessor :current_prompt
	attr_accessor :max_score
	attr_accessor :cards
	attr_accessor :prompts

	def initialize(options = {})
		@name = options[:name]
		@password = options[:password] if options[:enable_password]
		@max_players = options[:max_players].to_i || 4
		@creator = options[:creator]
		x = nil
		Game.games.each_with_index{|g, i| break x = i if g.has_player?(@creator) }
		if x
			games[x].remove_player(@creator)
		end
		@max_score = options[:max_score].to_i || 10
		if options[:card_packs]
			@card_packs = []
			options[:card_packs].each do |k,v|
				@card_packs.push(CardPack.find(v.to_i))
			end
		else
			@card_packs = [CardPack.where(:name=>"Standard").first]
		end	
		@prompts = []
		@card_packs.each do |card_pack|
			@prompts = @prompts + card_pack.prompts
		end
		unless options[:all_blanks]
			@blanks = options[:blank_count].to_i
			@cards = []
			load_cards
		end
		@current_player = @creator
		@players = [@creator]
		@creator.initialize_for_game
		@ready = false
		get_new_prompt
		deal_cards(@creator)
		Game.games.push(self)
	end

	def get_player(id)
		@players.each do |u|
			return u if u.id == id
		end
		nil
	end

	def select_cards(player, params)
		if player.select_cards(params, @current_prompt.blanks)
			return true, players_ready?
		else
			return false, false
		end
	end

	def load_cards
		@card_packs.each do |card_pack|
			@cards = @cards + card_pack.cards
		end
		i = 0
		while i < @blanks
			@cards.push(Card.blank)
			i += 1
		end
	end

	def deal_cards(player)
		if @cards
			while player.cards.count < 5
				player.cards.push(get_random_card)
			end
		else
			while player.cards.count < current_prompt.blanks
				player.cards.push(Card.blank)
			end
		end
	end

	def url
		"/games/" + name
	end

	def get_new_prompt
		@current_prompt = @prompts[rand(@prompts.count).to_i]
	end

	def ready?
		@ready
	end

	def players_ready?
		@ready = true
		players.each do |player|
			break @ready = false unless player.ready? || player == current_player
		end
		return @ready
	end

	def get_random_card
		if @cards.count == 0
			load_cards
		end
		return @cards.delete_at(rand(@cards.count).to_i)
	end

	def end_game
		players.each do |player|
			player.selected_cards.each do |c|
				cards.push(c.card)
			end
			player.cards.each do |c|
				cards.push(c)
			end
			player.score = 0
			player.selected_cards = []
			player.pass = false
		end
		@ready = false
	end


	def start_next_game
		get_prompt
		players.each do |p| 
			deal_cards(p)
		end
	end

	def select_winner(cards_hash)
		player = nil
		players.each do |p|
			next if p == @current_player
			player = p
			p.selected_cards.each do |c|
				unless cards_hash.include?(c.id.to_s.to_sym)
					break player = nil
				end
			end
			break if player
		end
		return false unless player
		player.score = player.score + 1
		if player.score == max_score
			end_game
			PrivatePub.publish_to self.url, :method => "endGame", :event => {:winner => player.username}
		else
			init_next_round
			PrivatePub.publish_to self.url, :method => "selectWinner", :event => {:winner => player.username, :score => player.score}
		end
		return true
	end

	def init_next_round
		get_new_prompt
		players.each do |player|
			if cards
				player.selected_cards.each do |c|
					cards.push(c.card)
				end
			end
			player.selected_cards = []
			player.pass = false
		end
		players.each do |player|
			deal_cards(player)
		end
		@current_player = players[(players.index(@current_player) + 1) % players.count]
		@ready = false
	end

	def all_pass?
		p = true
		players.each do |player|
			break p = false unless player.pass || player == current_player
		end
		return p
	end

	def add_player(player)
		players.push(player)
		player.initialize_for_game
		deal_cards(player)
		PrivatePub.publish_to self.url, :method => "playerConnect", :event => {:player => player.username, :score => player.score, :player_id => player.id, :kicked => self.player_kicked?(player)}
	end

	def remove_player(player)
		if player == self.creator
			Game.delete(self)
		else
			@cards += player.cards if @cards
			player.selected_cards.each do |sc|
				cards.push(sc.card)
			end
			players.delete(player)
			PrivatePub.publish_to self.url, :method => "playerLeave", :event => {:player => player.username}
			if self.players_ready?
				if self.all_pass?
					self.init_next_round
					PrivatePub.publish_to self.url, :method => "allPass"
				else
					PrivatePub.publish_to self.url, :method => "showCards", :event => {:html => render_to_string(:partial => "/shared/show_cards", :locals => {:game => self})}
				end
			end
		end	
	end

	def kick_player(id)
		player = self.get_player(id)
		remove_player(player)
		pos = kicked_players.index(player.id)
		if pos
			banned_players.push(player)
			kicked_players.delete_at(pos)
			PrivatePub.publish_to self.url, :method => "banPlayer", :event => {:player => player.username}
		else
			kicked_players.push(player.id)
			PrivatePub.publish_to self.url, :method => "kickPlayer", :event => {:player => player.username}
		end
	end

	def banned_players
		@banned_players ||= []
	end

	def kicked_players
		@kicked_players ||= []
	end

	def player_kicked?(player)
		t = false
		kicked_players.each do |p|
			break t = true if p == player.id
		end
		return t
	end

	def player_banned?(player)
		t = false
		banned_players.each do |p|
			break t = true if p == player.id
		end
		return t
	end

	def has_player?(player)
		players.include?(player)
	end

	def delete
		Game.delete(self)
	end
end
