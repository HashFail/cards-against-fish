class HomeController < ApplicationController
	skip_before_filter :require_user

	def reload
		if Rails.env.development?
			Dir.entries("#{Rails.root}/app/models").each do |entry|
				load entry if entry =~ /.rb$/
			end
			Dir.entries("#{Rails.root}/app/controllers").each do |entry|
				load entry if entry =~ /.rb$/
			end
			render :text => "reloaded"
		else
			render :text => "nope"
		end
	end
end
