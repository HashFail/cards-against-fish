Cards::Application.routes.draw do
	devise_for :users, :controllers => {:registrations => "registrations"} 
	resources :games, :except => [:edit, :new] do
		member do
			post "join"
			post "select_cards"
			get "leave"
			post "remote_leave"
			post "get_cards"
			post "select_winner"
			post "start_next_round"
			post "remote_join"
			post "toggle_pass"
			post "kick_player"
			post "skip_player"
			post "new_message"
			post "subscribe"
			post "unsubscribe"
		end
		collection do
			get "get_kicked"
			get "get_banned"
		end
	end
	resources :card_packs, :except => [:edit, :update, :destroy] do
		resources :cards, :only => [:update, :create, :new]
		resources :prompts, :only => [:update, :create, :new]
		member do
			get "vote"
		end
	end
	resources :cards, :only => [] do
		member do
			post "preview"
		end
	end
	match '/about', :to => 'home#about'
	match '/reload', :to => 'home#reload'
	root :to => "home#index"
end
