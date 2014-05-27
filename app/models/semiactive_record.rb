class SemiactiveRecord < ActiveRecord::Base

	self.abstract_class = true

	def self.pool
		return @pool ||= self.all(:order=>:id)
	end

	def self.all(options = {})
		return @pool ||= super(:order=>:id)
	end

	def self.delete(id)
		id = id.to_i
		pool.delete_at(pool.native_bindex{|r| id - r.id}) rescue nil
		super
	end

	def self.find(id)
		id = id.to_i
		return pool.native_bsearch{|r| id - r.id}
	end

	def self.where(options = {})
		return pool.select do |r|
			t = true
			options.each do |k, v|
				break t = false unless r.send(k) == v
			end
			t
		end
	end

	def save
		if self.new_record?
			self.class.pool.push(self)
		end
		super
	end

	def delete
		self.class.delete(id)
		super
	end

end
