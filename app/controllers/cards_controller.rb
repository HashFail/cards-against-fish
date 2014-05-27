class CardsController < ApplicationController
	before_filter :load_card_pack, :except => [:preview]
	before_filter :load_card, :except => [:new, :create]
	before_filter :validate_user, :except => [:preview]

	def preview
		render :text => "{\"word\" : \"#{@card.print(params)}\"}"
	end

	def create
		@card = Card.new(params[:card])
		@card.card_pack_id = @card_pack.id
		if @card.save
			render :text => "{\"card\" : #{@card.to_json}}"
		else
			render :text => "{\"errors\" : #{@card.errors.to_json}}"
		end
	end

	def update
		@card = Card.assign_attributes(params[:card])
		@card.card_pack_id = @card_pack.id
		if @card.save
			render :text => "{\"card\" : #{@card.to_json}}"
		else
			render :text => "{\"errors\" : #{@card.errors.to_json}}"
		end
	end

	private

	def load_card_pack
		@card_pack = CardPack.find(params[:card_pack_id])
		unless @card_pack
			flash[:error] = "Card pack not found"
			redirect_to card_packs_path
		end
	end

	def load_card
		@card = Card.find(params[:id])
		unless @card
			flash[:error] = "Card not found"
			redirect_to @card_pack
		end
	end

	def validate_user
		unless current_user == @card_pack.user || user.admin
			flash[:error] = "Permission denied"
			redirect_to @card_pack
		end
	end
end
