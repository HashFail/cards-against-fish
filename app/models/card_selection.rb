class CardSelection	
	methods = Card.instance_methods
	methods.each do |m|
		define_method(m) do |*args|
			@card.send(m, *args)
		end
	end

	methods = nil

	attr_accessor :params

	def ==(other)
		if other.is_a?(Card)
			return other.id == card.id
		else
			return other.card.id == self.card.id
		end
	end

	def initialize(options = {})
		@card = options[:card]
		@params = options[:params]
	end

	def print
		@card.print(@params)
	end
	
	def card
		@card
	end
end
