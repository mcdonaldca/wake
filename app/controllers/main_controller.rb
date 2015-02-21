class MainController < ApplicationController

	def index
		@graphic = true
		@graphic_name = "security_1.png"
		user = User.find 0
		user.sleep = 0
		user.save()
	end

	def select
		@graphic = true
		@graphic_name = "security_1.png"
	end

	def identity

		user = User.find 0
		user.name = params["name"]
		user.save()
		redirect_to dashboard_url
	end

	def dashboard

		@graphic = false

		user = User.find 0
		@name = user.name
		if not ["sir", "ma'am", "boss"].include? @name
			redirect_to select_url
		end

	end

	def asleep
		require 'json'

		user = User.find 0
		my_hash = {:SLEEP => user.sleep}
		@sleep =  JSON.generate(my_hash)

		render json: @sleep
	end

	def pebble_nod
		user = User.find 0
		user.sleep = 1
		user.save()

		require 'json'

		my_hash = {:SUCCESS => 1}
		@success =  JSON.generate(my_hash)

		render json: @success
	end

	def fitbit_sleep
		user = User.find 0
		user.sleep = 1
		user.save()

		require 'json'

		my_hash = {:SUCCESS => 1}
		@success =  JSON.generate(my_hash)

		render json: @success
	end

	def fitbit
		redirect_to dashboard_url
	end

	def reset
		user = User.find 0
		user.name = ""
		user.sleep = 0
		redirect_to root_url
	end

end
