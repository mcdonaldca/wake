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

		@smartthings_check_1 = user.smartthings_access_token
		@smartthings_check_2 = user.smartthings_api_endpoint

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

	def sleep_watch

		user = User.find 0
		@name = user.name
		@sleep_watch = user.sleep_watch

	end

	def set_sleep_watch
		mode = params["mode"]
		user = User.find 0

		if mode == "green"
			user.sleep_watch = 2
		elsif mode == "yellow"
			user.sleep_watch = 1
		else
			user.sleep_watch = 0
		end

		user.save()

		redirect_to sleep_watch_url
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
			:method => 'GET',  
			:fallback_method => 'GET',  
			:status_callback_method => 'GET',    
			:record => 'false'
		})
		 
	end

	def phone_answered 

		user = User.find 0

		if user.sleep != 0
			user.sleep = 0
			user.save()
		end

	end

	def handle_television

		start = get_offset()
		
		job_id =
      Rufus::Scheduler.singleton.in '1s' do
      	finish = get_offset()

        if start != finish
		    	response = Net::HTTP.get(URI("http://10.19.188.238:8080/remote/processKey?key=pause"))
		    end
      end

	end

	def handle_home 
		require 'net/http'

		user = User.find 0

		uri = URI(user.smartthings_api_endpoint + "/switch/off")
		req = Net::HTTP::Post.new(uri)
		req.content_type = 'application/json'
		req.add_field("authorization", 'Bearer ' + user.smartthings_access_token)

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		response = http.request(req)

		redirect_to dashboard_url
	end

	def get_offset

		response = Net::HTTP.get_response(URI("http://10.19.188.238:8080/tv/getTuned")).body
		return JSON.parse(response)["offset"]

	end

	def fitbit_auth

		redirect_to dashboard_url

	end

	def smartthings_auth

		auth_code = params["code"]
		client_id = "627d1e37-7ac3-4368-8a28-4028570bc3a9"
		client_secret = "1b4cfc4b-20b4-4cff-a424-0254b325c1b9"
		redirect_encoded = "http%3A%2F%2Fwake-treehacks.herokuapp.com%2Fsmartthings"

		url = "https://graph.api.smartthings.com/oauth/token?grant_type=authorization_code&client_id=#{client_id}&client_secret=#{client_secret}&redirect_uri=https%3A%2F%2Fgraph.api.smartthings.com%2Foauth%2Fcallback&scope=app&code=#{auth_code}"

		response = Net::HTTP.get_response(URI(url)).body
		#access_token = JSON.parse(response)["access_token"]
		access_token = "22853c41-2f0d-4c0a-bb50-0dc2ff1c84a8"
		api_endpoint = "https://graph.api.smartthings.com/api/smartapps/installations/bfc3f42a-835e-4082-b88f-abb1d8ce5e83"

		user = User.find 0
		user.smartthings_access_token = access_token
		user.smartthings_api_endpoint = api_endpoint
		user.save()

		redirect_to dashboard_url
	end

	def reset
		user = User.find 0
		user.name = ""
		user.sleep = 0
		user.sleep_watch = 0
		user.smartthings_access_token = nil
		user.smartthings_api_endpoint = nil
		user.directv_ip = nil
		user.aural = 1
		user.pebble_loc = "wrist"
		user.save()
		redirect_to root_url
	end

end
