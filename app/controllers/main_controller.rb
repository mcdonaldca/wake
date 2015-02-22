class MainController < ApplicationController

  # Start page
	def index
		@graphic = true
		@graphic_name = "security_1.png"
		user = User.find 0
		user.sleep = 0
		user.save()
	end

	# Choose your name!
	def select
		@graphic = true
		@graphic_name = "security_1.png"
	end

  # Associate name with user, head to dashboard
	def identity
		user = User.find 0
		user.name = params["name"]
		user.save()
		redirect_to dashboard_url
	end

  # Displays overall info
	def dashboard
		user = User.find 0

		@name = user.name
		@sleep_watch = user.sleep_watch
		@graphic = false

		@smartthings_check_1 = user.smartthings_access_token
		@smartthings_check_2 = user.smartthings_api_endpoint
		@directv_check = user.directv_ip

		# Send them back to select stage if they tried to skip it
		if not ["sir", "ma'am", "boss"].include? @name
			redirect_to select_url
		end
	end

	# Displays specific sleep watch settings
	def sleep_watch
		user = User.find 0

		@name = user.name
		@sleep_watch = user.sleep_watch
		@aural = user.aural
		@pebble_loc = user.pebble_loc
	end

	# Sets the state of sleep watch
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

	# Set the state of aural alarms
	def set_aural
		mode = params["mode"]
		user = User.find 0

		if mode == "off"
			user.aural = 0
		else 
			user.aural = 1
		end

		user.save()
		redirect_to sleep_watch_url
	end

	# Set the state of the pebble location
	def set_pebble_loc
		loc = params["loc"]
		user = User.find 0

		if loc == "head"
			user.pebble_loc = loc
		else
			user.pebble_loc = "wrist"
		end

		user.save()
		redirect_to sleep_watch_url
	end

	################################
	#                              #
	#  Simple API                  #
	#                              #
	################################

	# Pebbly queries to see if it should go off
	# TODO: rename asleep to awaken
	def asleep
		user = User.find 0
		Rails.logger.info "herro, perbble #{user.sleep}"
		# TODO: rename SLEEP to BUZZ
		require "json"
		my_hash = {:SLEEP => user.sleep}
		@wake = JSON.generate(my_hash)
		render json: @wake
		
	end

	# Pebble pings this when it detects a nod
	def pebble_nod
		require "json"
		user = User.find 0

		if user.pebble_loc != "wrist" and should_wake 
			user.sleep = 1
			user.save()
			sleep_detected
			my_hash = {:SUCCESS => 1}
		else
			my_hash = {:SUCCESS => 0}
		end

		@wake = JSON.generate(my_hash)
		render json: @wake
	end

	# Pebble pings this when the vibration alarm is silenced
	def pebble_button
		user = User.find 0

		if user.sleep != 0
			user.sleep = 0
			user.save()
		end

		require "json"
		my_hash = {:SUCCESS => 1}
		@wake = JSON.generate(my_hash)
		render json: @wake
	end

	# FitBit pings this when it detects user sleep
	def fitbit_sleep
		user = User.find 0

		if should_wake
			user.sleep = 1
			user.save()
			sleep_detected
		end

		require "json"
		my_hash = {:SUCCESS => 1}
		@wake = JSON.generate(my_hash)
		render json: @wake
	end

	################################
	#                              #
	#  Modular Sleep Handlers      #
	#                              #
	################################

	# If the user has fallen asleep
	def sleep_detected
		user = User.find 0
		if user.aural == 1
			make_sound
		end
	end

	def should_wake
		
		# TODO: check in in meeting
		# TODO: check if driving

		user = User.find 0

		# If user isn't in a meeting & isn't driving
		# Check if they have sleep watch turned off
		Rails.logger.info user.sleep_watch
		if user.sleep_watch == 0
			Rails.logger.info "callin thangs"
			handle_television
			handle_home
			return false
		end

		# If user isn't in a meeting & isn't driving
		# Don't have sleep watch turned off
		# Check for nap mode
		if user.sleep_watch == 1
			handle_television
			job_id =
	      Rufus::Scheduler.singleton.in '27s' do
	      	user.sleep = 1
	      	user.save()
	      	sleep_detected
	      end
		end

		# If user isn't in a meeting & isn't driving
		# Don't have sleep watch turned off
		# Don't have nap mode on, so wake 'em up
		return true
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

  # Exists to be an endpoint for twilio call
	def phone_answered 
	end

  # Check the television to see if it needs to be paused
	def handle_television
		start = get_offset
		
		# Check offset again 1 second later
		job_id =
      Rufus::Scheduler.singleton.in '1s' do
      	finish = get_offset

      	# If the offsets are different, pause whatever is playing
        if start != finish
        	response = Net::HTTP.get(URI("http://68.65.171.134:8080/remote/processKey?key=pause"))
		    	#response = Net::HTTP.get(URI("http://10.19.188.238:8080/remote/processKey?key=pause"))
		    end
      end

	end

  # Find the user's current location in the movie
	def get_offset
		response = Net::HTTP.get_response(URI("http://68.65.171.134:8080/tv/getTuned")).body
		return JSON.parse(response)["offset"]
	end

  # If we're connected to the smart home, turn off the light
	def handle_home 
		require 'net/http'

		user = User.find 0

		# Make sure we have the necessary tokens
		unless user.smartthings_api_endpoint.nil? or user.smartthings_access_token.nil?		
			uri = URI(user.smartthings_api_endpoint + "/switch/off")
			req = Net::HTTP::Post.new(uri)
			req.content_type = 'application/json'
			req.add_field("authorization", 'Bearer ' + user.smartthings_access_token)

			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			response = http.request(req)
		end	
	end

  ################################
	#                              #
	#  Auth Handling               #
	#                              #
	################################

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

  ################################
	#                              #
	#  Reset                       #
	#                              #
	################################

	def reset
		user = User.find 0
		user.name = ""
		user.sleep = 0
		user.sleep_watch = 0
		user.smartthings_access_token = nil
		user.smartthings_api_endpoint = nil
		user.directv_ip = "68.65.171.134"
		user.aural = 1
		user.pebble_loc = "wrist"
		user.save()
		redirect_to root_url
	end

end
