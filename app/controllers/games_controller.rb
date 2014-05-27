class GamesController < ApplicationController
	skip_before_filter :require_user
	before_filter :load_game, :except => [:index, :create, :get_kicked, :get_banned]
	before_filter :require_user

	def current_user
		return @current_user if @current_user
		user_id = session["warden.user.user.key"][0][0] rescue 0
		if @game
			return @current_user = @game.get_player(user_id) || warden.authenticate(:scope => :user)
		else
			return @current_user = warden.authenticate(:scope => :user)
		end
	end

	def subscribe
		Thread.kill(current_user.thread) if current_user.thread
		current_user.thread = nil
		render :text => ""
	end

	def unsubscribe
		current_user.thread = Thread.new do
			sleep(5)
			@game.remove_player(current_user)
		end
		render :text => ""
	end

	def index
		@games = Game.games
	end

	def create
		if params[:game][:name].empty?
			render :text => "{\"error\" : \"Name can't be blank. \"}"
		elsif params[:password_enabled] && params[:password].empty?
			render :text => "{\"error\" : \"Password cannot be enabled and blank. \"}"
		elsif Game.find_by_name(params[:game][:name])
			render :text => "{\"error\" : \"A game with that name already exists. \"}"
		else
			@game = Game.new(params[:game].merge({:creator => current_user}))
			render :text => "{\"url\" : \"#{@game.url}\"}"
		end
	end

	def destroy
		if current_user == @game.creator
			@game.delete
		end
		render :text => ""
	end

	def join
		if @game.players.include?(current_user)
			redirect_to @game.url
		elsif @game.players.count == @game.max_players
			flash[:error] = "That game is full."
			redirect_to games_path
		elsif @game.player_banned?(current_user)
			flash[:error] = "You have been banned from that game."
			redirect_to games_path
		elsif @game.password.nil? || @game.password == params[:password]
			@game.add_player(current_user)
			redirect_to @game.url
		else
			flash[:error] = "Incorrect password."
			redirect_to games_path
		end
	end

	def start_next_round
		if current_user == @game.creator
			PrivatePub.publish_to @game.url, :method => "startNextRound", :event => {:prompt => { :text => @game.current_prompt.text, :blanks => @game.current_prompt.blanks, :cardPack => @game.current_prompt.card_pack.name }, :cardCzar => @game.current_player.username }
		end
		render :text => ""
	end

	def get_cards
		render :partial => "/shared/user_cards"
	end

	def remote_join
		if @game.players.include?(current_user)
			render :text => "{\"sucess\" : true, \"url\" : \"#{@game.url}\" }"
		elsif
			render :text => "{\"sucess\" : false, \"error\" : \"That game is full.\" }"
		elsif @game.password.nil? || @game.password && @game.password == params[:password]
			@game.add_player(current_user)
			render :text => "{\"sucess\" : true, \"url\" : \"#{@game.url}\" }"
		else
			render :text => "{\"sucess\" : false, \"error\" : \"Incorrect password.\" }"
		end
	end

	def show
		if !@game.players.include?(current_user)
			if @game.password
				render :action => "join"
			elsif @game.player_banned?(current_user)
				flash[:error] = "You have been banned from that game."
				redirect_to games_path
			else
				@game.add_player(current_user)
			end
		end
	end

	def select_cards
		if @game.current_player != current_user && !current_user.ready? && params[:cards] && params[:cards].count == @game.current_prompt.blanks
			success, ready = @game.select_cards(current_user, params[:cards])
			if success
				if ready
					PrivatePub.publish_to @game.url, :method => "showCards", :event => {:html => render_to_string(:partial => "/shared/show_cards", :locals => {:game => @game})}
				end
				PrivatePub.publish_to @game.url, :method => "changeStatus", :event => {:player => current_user.username, :status => "ready"}
				render :text => "success"
			else
				render :text => "failure"
			end
		else
			render :text => "failure"
		end
	end

	def toggle_pass
		current_user.pass = !current_user.pass
		if @game.players_ready?
			if @game.all_pass?
				@game.init_next_round
				PrivatePub.publish_to @game.url, :method => "allPass"
			else
				PrivatePub.publish_to @game.url, :method => "showCards", :event => {:html => render_to_string(:partial => "/shared/show_cards", :locals => {:game => @game})}
			end
		end
		PrivatePub.publish_to @game.url, :method => "changeStatus", :event => {:player => current_user.username, :status => current_user.pass ? "pass" : "not ready"}
		render :text => ""
	end

	def skip_player
		if current_user == @game.creator
			player = @game.get_player(params[:player])
			player.pass = !player.pass
			if @game.players_ready?
				if @game.all_pass?
					@game.init_next_round
					PrivatePub.publish_to @game.url, :method => "allPass"
				else
					PrivatePub.publish_to @game.url, :method => "showCards", :event => {:html => render_to_string(:partial => "/shared/show_cards", :locals => {:game => @game})}
				end
			end
			PrivatePub.publish_to @game.url, :method => "skipPlayer", :event => {:player => player.username}
		end
		render :text => ""
	end 

	def new_message
		PrivatePub.publish_to @game.url, :method => "newMessage", :event => {:message => current_user.username + ": " + params[:message]}
		render :text => ""
	end

	def kick_player
		if current_user == @game.creator
			@game.kick_player(params[:player].to_i)
		end
		render :text => ""
	end

	def leave
		@game.remove_player(current_user)
		redirect_to games_path
	end

	def remote_leave
		@game.remove_player(current_user)
		render :text => ""
	end

	def select_winner
		if current_user == @game.current_player && @game.select_winner(params[:cards])
			render :text => "success"
		else
			render :text => "failure"
		end
	end

	def get_kicked
		flash[:error] = "You were kicked from the game."
		redirect_to games_path
	end

	def get_banned
		flash[:error] = "You were banned from the game."
		redirect_to games_path
	end

	private
	
	def load_game
		@game = Game.find_by_name(params[:id])
		unless @game
			flash[:error] = "Game not found."
			redirect_to games_path
		end
	end
end
