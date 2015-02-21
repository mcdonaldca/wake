class MainController < ApplicationController

	def index
		@graphic = true
		@graphic_name = "security_1.png"
		session[:asleep] = 0
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

		my_hash = {:SLEEP => session[:asleep]}
		@sleep =  JSON.generate(my_hash)

		render json: @sleep
	end

	def pebble_nod
		session[:asleep] = 1
	end

	def reset
		session = nil
		redirect_to root_url
	end

	def fitbit_sleep
		session[:asleep] = 1
	end

	def fitbit
		redirect_to dashboard_url
	end

end
