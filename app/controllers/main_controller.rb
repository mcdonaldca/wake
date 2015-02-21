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
		@sleep_watch = user.sleep_watch
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

	def pebble_button
		user = User.find 0
		user.sleep = 0
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
		user.sleep_watch = 0
		redirect_to root_url
	end

	def sleep_watch
	end

	def make_sound
		 #curl -X POST https://api.twilio.com/2010-04-01/Accounts/AC77847336a48c6aa58c4f1c0e7cbf67ae/Calls.json \
   #-u AC77847336a48c6aa58c4f1c0e7cbf67ae:846b1a6d20f408b88b3a4d78a8604431 \
   #--data-urlencode "From=+19899410565" \
   #--data-urlencode "To=+19894883855" \
   #--data-urlencode 'Url=http%3A%2F%2Ftwimlets.com%2Fecho%3FTwiml%3D%253CResponse%253E%253CSay%253EThis%2Bis%2Ba%2Btest%2521%253C%252FSay%253E%253C%252FResponse%253E'
	end

end
