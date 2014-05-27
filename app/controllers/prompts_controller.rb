class PromptsController < ApplicationController
	before_filter :load_card_pack
	before_filter :load_card, :except => [:new, :create]
	before_filter :validate_user

	def create
		@prompt = Prompt.new(params[:prompt])
		@prompt.card_pack_id = @card_pack.id
		if @prompt.save
			render :text => "{\"prompt\" : #{@prompt.to_json}}"
		else
			render :text => "{\"errors\" : #{@prompt.errors.to_json}}"
		end
	end

	def update
		@prompt = Card.assign_attributes(params[:card])
		@prompt.card_pack_id = @card_pack.id
		if @prompt.save
			render :text => "{\"prompt\" : #{@prompt.to_json}}"
		else
			render :text => "{\"errors\" : #{@prompt.errors.to_json}}"
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

	def load_prompt
		@prompt = Prompt.find(params[:id])
		unless @prompt
			flash[:error] = "Card not found"
			redirect_to @card_pack
		end
	end

	def validate_user
		unless current_user == @card_pack.user
			flash[:error] = "Permission denied"
			redirect_to @card_pack
		end
	end
end
