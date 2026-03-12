extends Node


const OAUTH_DOMAIN: String =  "dev-nwibq0byvol7tlrj.us.auth0.com"
const OAUTH_CLIENT_ID: String = "Rcw5Sgav4iJ0vYTIA9UTUXKEXZvDeMOs"
const API_AUDIENCE: String = "urn:cashio:api"
const FRONTEND_DOMAIN: String = "cashio-web.vercel.app"
const WEB_REDIRECT_URI: String = "https://%s/callback.html" % FRONTEND_DOMAIN
const AUTHORIZATION_URL: String = "https://%s/authorize" % OAUTH_DOMAIN
const FIREBASE_API_KEY: String = "AIzaSyCmCi8oEnYyaih1ElMMGuIDiIzzVQQTyoI"

var STATE: String = str(randi()) + str(Time.get_ticks_usec())
var code_challenge: String = ""
var code_verifier: String = ""
var auth_code: String = ""
var timeout_timer: Timer
var auth_is_active: bool = true
var AUTH_ACTIVE_DURATION: float = 120

func _ready() -> void:
	set_process(false)
	SignalManager.signout_successful.connect(_on_signout_successful)

func _on_signout_successful() -> void:
	var access_token = JavaScriptBridge.eval("localStorage.getItem('cashio_saved_access_token')")
	if access_token:
		JavaScriptBridge.eval("localStorage.removeItem('cashio_saved_access_token')")

func try_silent_auth() -> void:
	var access_token = JavaScriptBridge.eval("localStorage.getItem('cashio_saved_access_token')")
	if access_token:
		HttpNetworkManager.request_social_auth(access_token)
	else:
		SignalManager.emit_open_loading_screen_signal(false)

func generate_code_verifier() -> String:
	var bytes = Crypto.new().generate_random_bytes(32)
	return Marshalls.raw_to_base64(bytes)\
		.replace("+","-")\
		.replace("/","_")\
		.replace("=","")

func generate_code_challenge(verifier:String) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())

	var hash = ctx.finish()

	return Marshalls.raw_to_base64(hash)\
		.replace("+","-")\
		.replace("/","_")\
		.replace("=","")

func sign_in() -> void:
	print("signin clicked")
	auth_is_active = true
	code_verifier = generate_code_verifier()
	code_challenge = generate_code_challenge(code_verifier)
	SignalManager.emit_open_loading_screen_signal(true)
	timeout_timer = Timer.new()
	add_child(timeout_timer)
	timeout_timer.one_shot = true
	timeout_timer.timeout.connect(_on_timeout_timer_timeout)
	timeout_timer.wait_time = AUTH_ACTIVE_DURATION
	timeout_timer.start()
	set_process(true)

	var post_load : String = AUTHORIZATION_URL + "?" + \
	"client_id=" + OAUTH_CLIENT_ID + "&response_type=code" + "&redirect_uri=" + WEB_REDIRECT_URI + \
	"&audience=urn:cashio:api" + "&scope=openid%20profile%20email" + "&code_challenge=" + \
	code_challenge + "&code_challenge_method=S256" + "&state=" + STATE + "&connection=google-oauth2"
		
	if OS.get_name() == "Web":

		JavaScriptBridge.eval("window.addEventListener('message', (event) => {
		    if (event.origin !== window.location.origin) return;

		    const { code, state } = event.data;

			console.log('OAuth received:', code, state);

			sessionStorage.setItem('code', code);
			sessionStorage.setItem('state', state);
			//localStorage.setItem('code', code);
			//localStorage.setItem('state', state);
		});")
		JavaScriptBridge.eval(
			"window.oauthPopup = window.open(" +
			JSON.stringify(post_load) +
			", 'oauthPopup', 'width=500,height=600');")



func _process(delta: float) -> void:
	if auth_is_active:
		if OS.get_name() == "Web":
			session_check(true)

func session_check(condition: bool) -> bool:
	var code = JavaScriptBridge.eval("sessionStorage.getItem('code')")
	var state = JavaScriptBridge.eval("sessionStorage.getItem('state')")
	print("code for auth: ", code)
	print("state for auth: ", state)
	if state and code:
		if condition:
			if state != STATE:
				print("state wasnt the same")
				set_process(false)
				return false
		auth_code = code
		exchange_code_for_token(code)
		print("state was correct and code was received: ", code)
		set_process(false)
		return true
	else:
		return false

func exchange_code_for_token(code: String) -> void:
	if auth_is_active:
		var url: String = "https://" + OAUTH_DOMAIN + "/oauth/token"
		var post_body: Dictionary = {
			"grant_type": "authorization_code",
			"client_id": OAUTH_CLIENT_ID,
			"code": code,
			"redirect_uri": WEB_REDIRECT_URI,
			"code_verifier": code_verifier
		}
		var http: HTTPRequest = HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			print("exchange code for token result: ", result)
			print("exchange code for token response code: ", response_code)
			print("exchange code for token body: ", JSON.stringify(body.get_string_from_utf8()))
			timeout_timer.stop()
			if response_code == 200:
				var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
				if response.has("access_token"):
					JavaScriptBridge.eval("localStorage.setItem('cashio_saved_access_token'," + JSON.stringify(response.access_token) + ")")
					HttpNetworkManager.request_social_auth(response.access_token)
			else:
				SignalManager.emit_notice_signal("Issue Authenticating")
				SignalManager.emit_open_loading_screen_signal(false)
			)
		http.request(url, ["Content-Type: application/json"],HTTPClient.METHOD_POST, JSON.stringify(post_body))

func extract_code_from_request(request: String) -> String:
	var regex = RegEx.new()
	regex.compile("code=([^& ]+)")
	var result = regex.search(request)

	if result:
		return result.get_string(1)

	return ""

func _on_timeout_timer_timeout() -> void:
	auth_is_active = false
	set_process(false)
	SignalManager.emit_open_loading_screen_signal(false)
	SignalManager.emit_notice_signal("Timeout")


#this is backup of the code above
#extends Node
#
#
#const OAUTH_DOMAIN: String =  "dev-nwibq0byvol7tlrj.us.auth0.com"
#const OAUTH_CLIENT_ID: String = "Rcw5Sgav4iJ0vYTIA9UTUXKEXZvDeMOs"
#const API_AUDIENCE: String = "urn:cashio:api"
#const MOBILE_REDIRECT_URI: String = "cashio://auth/callback"
#const FRONTEND_DOMAIN: String = "cashio-web.vercel.app"
#const WEB_REDIRECT_URI: String = "https://%s/callback.html" % FRONTEND_DOMAIN
#const AUTHORIZATION_URL: String = "https://%s/authorize" % OAUTH_DOMAIN
#const FIREBASE_API_KEY: String = "AIzaSyCmCi8oEnYyaih1ElMMGuIDiIzzVQQTyoI"
#
#var STATE: String = str(randi()) + str(Time.get_ticks_usec())
#var code_challenge: String = ""
#var code_verifier: String = ""
#var auth_code: String = ""
#var current_redirect_uri: String = ""
#var server :TCPServer = TCPServer.new()
#var timeout_timer: Timer
#var auth_is_active: bool = true
#
#func _ready() -> void:
	#set_process(false)
#
#func generate_code_verifier() -> String:
	#var bytes = Crypto.new().generate_random_bytes(32)
	#return Marshalls.raw_to_base64(bytes)\
		#.replace("+","-")\
		#.replace("/","_")\
		#.replace("=","")
#
#func generate_code_challenge(verifier:String) -> String:
	#var ctx = HashingContext.new()
	#ctx.start(HashingContext.HASH_SHA256)
	#ctx.update(verifier.to_utf8_buffer())
#
	#var hash = ctx.finish()
#
	#return Marshalls.raw_to_base64(hash)\
		#.replace("+","-")\
		#.replace("/","_")\
		#.replace("=","")
#
#func sign_in() -> void:
	#print("signin clicked")
	#auth_is_active = true
	#code_verifier = generate_code_verifier()
	#code_challenge = generate_code_challenge(code_verifier)
	#SignalManager.emit_open_loading_screen_signal(true)
	#timeout_timer = Timer.new()
	#add_child(timeout_timer)
	#timeout_timer.one_shot = true
	#timeout_timer.timeout.connect(_on_timeout_timer_timeout)
	#timeout_timer.wait_time = 120
	#timeout_timer.start()
	#set_process(true)
	#if OS.get_name() == "Web" or OS.get_name() == "Windows":
		#current_redirect_uri = WEB_REDIRECT_URI
	#elif OS.get_name() == "Android":
		#current_redirect_uri = MOBILE_REDIRECT_URI
#
	#var post_load : String = AUTHORIZATION_URL + "?" + \
	#"client_id=" + OAUTH_CLIENT_ID + "&response_type=code" + "&redirect_uri=" + current_redirect_uri + \
	#"&audience=urn:cashio:api" + "&scope=openid%20profile%20email" + "&code_challenge=" + \
	#code_challenge + "&code_challenge_method=S256" + "&state=" + STATE + "&connection=google-oauth2"
		#
	#if OS.get_name() == "Web":
#
		#JavaScriptBridge.eval("window.addEventListener('message', (event) => {
			#if (event.origin !== window.location.origin) return;
#
			#const { code, state } = event.data;
#
			#console.log('OAuth received:', code, state);
#
			#sessionStorage.setItem('code', code);
			#sessionStorage.setItem('state', state);
		#});")
		#JavaScriptBridge.eval(
			#"window.oauthPopup = window.open(" +
			#JSON.stringify(post_load) +
			#", 'oauthPopup', 'width=500,height=600');")
	#else:
		#server.listen(8000)
		#OS.shell_open(post_load)
#
#
#func _process(delta: float) -> void:
	#if auth_is_active:
		#if OS.get_name() == "Web":
			#session_check(true)
		#elif OS.get_name() == "Windows":
			#if server.is_connection_available():
	#
				#var connection = server.take_connection()
				#var request = connection.get_string(connection.get_available_bytes())
				#var code = extract_code_from_request(request)
	#
				#if code != "":
					#exchange_code_for_token(code)
	#
				#connection.put_data(
					#"HTTP/1.1 200 OK\r\n\r\nLogin successful! Close this page".to_utf8_buffer()
				#)
	#
				#connection.disconnect_from_host()
				#set_process(false)
#
#func session_check(condition: bool) -> bool:
	#var code = JavaScriptBridge.eval("sessionStorage.getItem('code')")
	#var state = JavaScriptBridge.eval("sessionStorage.getItem('state')")
	#print("code for auth: ", code)
	#print("state for auth: ", state)
	#if state and code:
		#if condition:
			#if state != STATE:
				#print("state wasnt the same")
				#set_process(false)
				#return false
		#auth_code = code
		#exchange_code_for_token(code)
		#print("state was correct and code was received: ", code)
		#set_process(false)
		#return true
	#else:
		#return false
#
#func exchange_code_for_token(code: String) -> void:
	#if auth_is_active:
		#var url: String = "https://" + OAUTH_DOMAIN + "/oauth/token"
		#var post_body: Dictionary = {
			#"grant_type": "authorization_code",
			#"client_id": OAUTH_CLIENT_ID,
			#"code": code,
			#"redirect_uri": current_redirect_uri,
			#"code_verifier": code_verifier
		#}
		#var http: HTTPRequest = HTTPRequest.new()
		#add_child(http)
		#http.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			#print("exchange code for token result: ", result)
			#print("exchange code for token response code: ", response_code)
			#print("exchange code for token body: ", JSON.stringify(body.get_string_from_utf8()))
			#timeout_timer.stop()
			#if response_code == 200:
				#var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
				#if response.has("access_token"):
					#HttpNetworkManager.request_social_auth(response.access_token)
			#else:
				#SignalManager.emit_notice_signal("Issue signning in")
				#SignalManager.emit_open_loading_screen_signal(false)
			#)
		#http.request(url, ["Content-Type: application/json"],HTTPClient.METHOD_POST, JSON.stringify(post_body))
#
#func extract_code_from_request(request: String) -> String:
	#var regex = RegEx.new()
	#regex.compile("code=([^& ]+)")
	#var result = regex.search(request)
#
	#if result:
		#return result.get_string(1)
#
	#return ""
#
#func _on_timeout_timer_timeout() -> void:
	#auth_is_active = false
	#set_process(false)
	#server.stop()
	#SignalManager.emit_open_loading_screen_signal(false)
	#SignalManager.emit_notice_signal("Timeout")
