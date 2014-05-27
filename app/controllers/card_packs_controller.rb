class CardPacksController < ApplicationController
	before_filter :load_card_pack, :except => [:new, :create, :index]

	def new
		@card_pack = CardPack.new
	end

	def create
		@card_pack = CardPack.new(params[:card_pack])
		@card_pack.user_id = current_user.id
		@card_pack.save
		redirect_to @card_pack
	end

	def index
		@card_packs = CardPack.all
	end

	def vote
		@vote = Vote.first_or_initialize(:card_pack_id => @card_pack.id, :user_id => User.first)
		@vote.up = params[:up]
		@vote.save
		render :text => "Success"
	end

	private

	def load_card_pack
		@card_pack = CardPack.find(params[:id])
		unless @card_pack
			flash[:error] = "Card pack not found"
			redirect_to card_packs_path
		end
	end
end
