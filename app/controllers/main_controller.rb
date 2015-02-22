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

		# Send them back to select stage if they tried to skip it
		if not ["sir", "ma'am", "boss"].include? @name
			redirect_to select_url
		end

		@smartthings_check_1 = user.smartthings_access_token
		@smartthings_check_2 = user.smartthings_api_endpoint
		@directv_check = user.directv_ip
		@fitbit_check_1 = user.fitbit_oauth_token
		@fitbit_check_2 = user.fitbit_oauth_secret

		require 'net/http'
		require 'securerandom'

		timestamp = Time.zone.now.to_i
		nonce = SecureRandom.hex()
		entries = ERB::Util.url_encode("oauth_consumer_key=33a270b7f4c947d7bc55190efbce9386&oauth_nonce=#{nonce}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=#{timestamp}&oauth_version=1.0")
		data = "POST&https%3A%2F%2Fapi.fitbit.com%2Foauth%2Frequest_token&" + entries
		key = ERB::Util.url_encode('e21d95d6d6144bf48e1a4252eb0a38be') + "&"

		require 'base64'
		require 'rubygems' # not necessary with ruby 1.9 but included for completeness 
		require 'hmac-sha1'

		hmac = Base64.encode64((HMAC::SHA1.new(key) << data).digest).strip

		uri = URI("https://api.fitbit.com/oauth/request_token")
		https = Net::HTTP.new(uri.host, uri.port)
		https.use_ssl = true

		request = Net::HTTP::Post.new(uri.path)

		request["oauth_callback"] = 'http%3A%2F%2Fwake-treehacks.herokuapp.com%2Ffitbit_auth'
		request["Authorization: OAuth oauth_consumer_key"] = '33a270b7f4c947d7bc55190efbce9386'
		request["oauth_consumer_key"] = '33a270b7f4c947d7bc55190efbce9386'
		request["oauth_nonce"] = nonce
		request["oauth_signature"] = hmac
		request["oauth_signature_method"] = 'HMAC-SHA1'
		request["oauth_timestamp"] = timestamp
		request["oauth_version"] = '1.0'

		request.set_form_data(
			'oauth_callback' => 'http%3A%2F%2Fwake-treehacks.herokuapp.com%2Ffitbit_auth',
			'oauth_consumer_key' => '33a270b7f4c947d7bc55190efbce9386',
			'oauth_nonce' => nonce,
			'oauth_signature' => hmac,
			'oauth_signature_method' => 'HMAC-SHA1',
			'oauth_timestamp' => timestamp
			)

		response = https.request(request).body
		#fitbit_oauth_token = JSON.parse
		user.fitbit_oauth_token = "2cfa2fdd547c6e195452af56dc2a79bf"
		user.fitbit_oauth_secret = "aafd0c1a7ef3798a5e6bb465a164b448"
		user.save()
		
		@url = "https://www.fitbit.com/oauth/authenticate?oauth_token=" + user.fitbit_oauth_token
		
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

		#if user.sleep != 0
			user.sleep = 0
			user.save()
		#end

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
		if user.sleep_watch == 0
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


	def fitbit_auth
		@req = params
	end

	def calendar_redirect
		google_api_client = Google::APIClient.new({
			application_name: 'Example Ruby application',
			application_version: '1.0.0'
		})

		google_api_client.authorization = Signet::OAuth2::Client.new({
			client_id: "737578715855-p1d4g7uf52jra0c9gtcff0imf96ded5p.apps.googleusercontent.com",
			client_secret: "dfb4sokyRDYj1gKTMh-GsXtR",	
			authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
			scope: 'https://www.googleapis.com/auth/calendar.readonly',
			redirect_uri: url_for(:action => :calendar_callback)
		})

		authorization_uri = google_api_client.authorization.authorization_uri

		redirect_to authorization_uri.to_s
	end

	def calendar_callback
		google_api_client = Google::APIClient.new({
	    	application_name: 'Example Ruby application',
	    	application_version: '1.0.0'
	  	})

		google_api_client.authorization = Signet::OAuth2::Client.new({
	    	client_id: "737578715855-p1d4g7uf52jra0c9gtcff0imf96ded5p.apps.googleusercontent.com",
	    	client_secret: "dfb4sokyRDYj1gKTMh-GsXtR",
	    	token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
	    	redirect_uri: url_for(:action => :calendar_callback),
	    	code: params[:code]
	  	})

	  	response = google_api_client.authorization.fetch_access_token!

	  	session[:access_token] = response['access_token']

	  	redirect_to url_for(:action => :calendar_fetch)
	end

	def calendar_fetch
	  	google_api_client = Google::APIClient.new({
	    	application_name: 'Example Ruby application',
	    	application_version: '1.0.0'
	  	})

	  	google_api_client.authorization = Signet::OAuth2::Client.new({
	    	client_id: "737578715855-p1d4g7uf52jra0c9gtcff0imf96ded5p.apps.googleusercontent.com",
	    	client_secret: "dfb4sokyRDYj1gKTMh-GsXtR",	
	    	access_token: session[:access_token]
	  	})

	  	google_calendar_api = google_api_client.discovered_api('calendar', 'v3')

	  	response = google_api_client.execute({
	    	api_method: google_calendar_api.calendar_list.list,
	    	parameters: {}
	  	})

	  	@items = response.data['items']

	  	@item_ids = []
	  	@items.each do |item|
	  		@item_ids.push(item.id)
	  	end
	  	response = google_api_client.execute({
	  			api_method: google_calendar_api.freebusy.query,
	  			parameters: {
	  				timeMin: Time.zone.now - 1.minute,
	  				timeMax: Time.zone.now + 10.minute,
	  				timeZone: Time.zone,
	  				groupExpansionMax: 75,
	  				items: @item_ids
	  		}})
	  	
	  	render json: response
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
		user.fitbit_oauth_token = nil
		user.fitbit_oauth_secret = nil
		user.aural = 1
		user.pebble_loc = "wrist"
		user.save()
		redirect_to root_url
	end

end
