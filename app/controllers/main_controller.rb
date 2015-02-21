class MainController < ApplicationController

	def index
		@graphic = true
		@graphic_name = "security_1.png"
	end

	def select
		@graphic = true
		@graphic_name = "security_1.png"
	end

	def identity

		session[:name] = params["name"]
		redirect_to dashboard_url
	end

	def dashboard

		if not ["sir", "ma'am", "boss"].include? session[:name] 
			redirect_to select_url
		end

		@graphic = false
	end

	def asleep
		require 'json'

		my_hash = {:SLEEP => 0}
		@sleep =  JSON.generate(my_hash)

		render json: @sleep
	end

end
