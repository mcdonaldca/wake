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

		require 'rubygems' # not necessary with ruby 1.9 but included for completeness 
		require 'twilio-ruby' 
		 
		# put your own credentials here 
		account_sid = 'AC77847336a48c6aa58c4f1c0e7cbf67ae' 
		auth_token = '846b1a6d20f408b88b3a4d78a8604431' 
		 
		# set up a client to talk to the Twilio REST API 
		@client = Twilio::REST::Client.new account_sid, auth_token 
		 
		@client.account.calls.create({
			:to => '+19894883855', 
			:from => '+19899410565', 
			:url => 'http://wake-treehacks.herokuapp.com/phone_answered',  
			:method => 'POST',  
			:fallback_method => 'GET',  
			:status_callback_method => 'GET',    
			:record => 'false'
		})
		 
	end

	def handle_television

		start = get_offset()

		job_id =
      Rufus::Scheduler.singleton.in '1s' do
      	finish = get_offset()

        if start < finish
		    	response = Net::HTTP.get(URI("http://10.19.188.238:8080/remote/processKey?key=pause"))
		    end
      end

	end

	def phone_answered 
		user = User.find 0
		if user.sleep != 0
			user.sleep = 0
			user.save()
		end
	end

	def get_offset

		response = Net::HTTP.get_response(URI("http://10.19.188.238:8080/tv/getTuned")).body
		offset = JSON.parse(response)["offset"]

		return offset.to_i

	end

	def test

    job_id =
      Rufus::Scheduler.singleton.in '5s' do
        Rails.logger.info "time flies, it's now #{Time.now}"
      end

    render :text => "scheduled job #{job_id}"
  end

end
