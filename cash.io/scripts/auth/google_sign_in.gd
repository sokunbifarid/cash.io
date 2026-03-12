extends Node

@onready var deeplink: Deeplink = $Deeplink
@export var AUTH_ACTIVE_DURATION: float = 120

var auth_active_timer: Timer = Timer.new()

const OAUTH_DOMAIN: String =  "dev-nwibq0byvol7tlrj.us.auth0.com"
const OAUTH_CLIENT_ID: String = "Rcw5Sgav4iJ0vYTIA9UTUXKEXZvDeMOs"
const API_AUDIENCE: String = "urn:cashio:api"
const MOBILE_REDIRECT_URI: String = "cashio://auth/callback"
const FRONTEND_DOMAIN: String = "cashio-web.vercel.app"
const AUTHORIZATION_URL: String = "https://%s/authorize" % OAUTH_DOMAIN

var STATE: String = str(randi()) + str(Time.get_ticks_usec())
var code_challenge: String = ""
var code_verifier: String = ""
var auth_code: String = ""
var timeout_timer: Timer
var auth_is_active: bool = true

func _ready() -> void:
	set_process(false)
	if Engine.has_singleton("DeeplinkPlugin"):
		deeplink.initialize()
		deeplink.deeplink_received.connect(_on_deeplink_received)

func _on_deeplink_received(url: DeeplinkUrl) -> void:
	var query: Dictionary = query_string_to_dict(url.get_query())
	if query.has("code") and query.has("state"):
		if query.state == STATE:
			exchange_code_for_token(query.code)
		else:
			timeout_timer.stop()
			SignalManager.emit_notice_signal("Issue Authenticating")
			SignalManager.emit_open_loading_screen_signal(false)

func query_string_to_dict(query: String) -> Dictionary:
	var result := {}
	
	for pair in query.split("&"):
		var parts = pair.split("=")
		if parts.size() == 2:
			var key = parts[0].uri_decode()
			var value = parts[1].uri_decode()
			result[key] = value
	
	return result

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

	var post_load : String = AUTHORIZATION_URL + "?" + \
	"client_id=" + OAUTH_CLIENT_ID + "&response_type=code" + "&redirect_uri=" + MOBILE_REDIRECT_URI + \
	"&audience=urn:cashio:api" + "&scope=openid%20profile%20email" + "&code_challenge=" + \
	code_challenge + "&code_challenge_method=S256" + "&state=" + STATE + "&connection=google-oauth2"
	OS.shell_open(post_load)

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

func exchange_code_for_token(code: String) -> void:
	if auth_is_active:
		var url: String = "https://" + OAUTH_DOMAIN + "/oauth/token"
		var post_body: Dictionary = {
			"grant_type": "authorization_code",
			"client_id": OAUTH_CLIENT_ID,
			"code": code,
			"redirect_uri": MOBILE_REDIRECT_URI,
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
					HttpNetworkManager.request_social_auth(response.access_token)
			else:
				SignalManager.emit_notice_signal("Issue signning in")
				SignalManager.emit_open_loading_screen_signal(false)
			)
		http.request(url, ["Content-Type: application/json"],HTTPClient.METHOD_POST, JSON.stringify(post_body))

func _on_timeout_timer_timeout() -> void:
	auth_is_active = false
	set_process(false)
	SignalManager.emit_open_loading_screen_signal(false)
	SignalManager.emit_notice_signal("Timeout")
















##old code that uses google popup signin sdk(GodotGoogleSignIn sdk)
#func _ready() -> void:
	#auth_active_timer.autostart = false
	#auth_active_timer.one_shot = true
	#auth_active_timer.wait_time = AUTH_ACTIVE_DURATION
	#get_tree().root.add_child.call_deferred(auth_active_timer)
	#
	#if check_os_is_android():
		#if Engine.has_singleton("GodotGoogleSignIn"):
			#google_sign_in = Engine.get_singleton("GodotGoogleSignIn")
			#connect_signal()
			#google_sign_in.initialize(FIREBASE_WEB_CLIENT_ID)
#
#func check_os_is_android() -> bool:
	#if OS.get_name() == "Android":
		#print("Current device is android")
		#return true
	#else:
		#printerr("Current device is not android")
		#return false

#func connect_signal() -> void:
	#google_sign_in.connect("sign_in_success", _on_sign_in_success)
	#google_sign_in.connect("sign_in_failed", _on_sign_in_failed)
	#google_sign_in.connect("sign_out_complete", _on_sign_out_complete)
	#auth_active_timer.timeout.connect(_on_auth_active_timer_timeout)
	#SignalManager.nakama_auth_user_with_google_worked_signal.connect(_on_nakama_auth_user_with_google_worked_signal)
	#oauth2.auth_started.connect(_on_auth_started)
	#oauth2.auth_success.connect(_on_auth_success)
	#oauth2.auth_error.connect(_on_auth_error)
	#oauth2.auth_cancelled.connect(_on_auth_cancelled)

#func mobile_sign_in():
	#SignalManager.emit_open_loading_screen_signal(true)
	#oauth2.authorize()

#func _on_auth_started():
	#print("Authentication started")
#
#func _on_auth_success(token_data: Dictionary):
	#print("Authentication success:", token_data)
	#SignalManager.emit_open_loading_screen_signal(false)
	#if token_data.has("access_token"):
		#HttpNetworkManager.request_social_auth(token_data.access_token)
	#else:
		#SignalManager.emit_notice_signal("Issue Authenticating")


#func _on_auth_error(msg: String):
	#print("Authentication error:", msg)
	#SignalManager.emit_notice_signal("Issue Authenticating")
	#SignalManager.emit_open_loading_screen_signal(false)
#
#func _on_auth_cancelled():
	#print("Authentication cancelled")
	#SignalManager.emit_notice_signal("Authentication Cancelled")
	#SignalManager.emit_open_loading_screen_signal(false)
#
#
#func sign_in() -> void:
	#if check_os_is_android():
		#SignalManager.emit_open_loading_screen_signal(true)
		#google_sign_in.signInWithGoogleButton()
		#auth_active_timer.start()
#
#func sign_out() -> void:
	#if google_sign_in:
		#google_sign_in.signOut()

#
#func _on_sign_in_success(id_token: String, email: String, display_name: String) -> void:
	#print("Signed in as: ", email)
	#print("Display name: ", display_name)
	##_sign_in_with_firebase(id_token)
	#HttpNetworkManager.request_social_auth(id_token)
	#print("google sign in decoded jwt: ", decode_jwt(id_token))
#
#func _on_sign_in_failed(error: String) -> void:
	#print("Sign-in Failed: ", error)
	#auth_active_timer.stop()
	#SignalManager.emit_notice_signal("Issue With Google Signin")
	#SignalManager.emit_open_loading_screen_signal(false)
#
#func _on_sign_out_complete() -> void:
	#print("Signed Out")
	#SignalManager.emit_open_loading_screen_signal(false)
	#SignalManager.emit_signout_successful_signal()
#
#func _on_auth_active_timer_timeout() -> void:
	#sign_out()
	#SignalManager.emit_notice_signal("Timeout")
#
#func _on_nakama_auth_user_with_google_worked_signal(condition: bool) -> void:
	#SignalManager.emit_open_loading_screen_signal(false)
	#if condition:
		#SignalManager.emit_signin_successful_signal()
	#else:
		#SignalManager.emit_notice_signal("Issue With Google Signin")
#
#func decode_jwt(token: String) -> Dictionary:
	#var parts = token.split(".")
	#if parts.size() != 3:
		#print("Invalid JWT")
		#return {}
#
	#var payload = parts[1]
#
	## Base64URL -> Base64
	#payload = payload.replace("-", "+").replace("_", "/")
#
	## Fix padding
	#while payload.length() % 4 != 0:
		#payload += "="
#
	#var decoded = Marshalls.base64_to_utf8(payload)
#
	#var json = JSON.parse_string(decoded)
#
	#return json

#func _sign_in_with_firebase(google_id_token: String) -> void:
	#var url: String = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=" + FIREBASE_API_KEY
	#var body: Dictionary = {
		#"postBody": "id_token=%s&providerId=google.com" % google_id_token,
		#"requestUri": "http://localhost",
		#"returnIdpCredential": true,
		#"returnSecureToken": true
	#}
	#var http: HTTPRequest = HTTPRequest.new()
	#add_child(http)
	#print("google sign in, http node is in tree: ", http.is_inside_tree())
	#http.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
		#print("google sign in sign in with firebase result code: ", result)
		#print("google sign in sign in with firebase response code: ", response_code)
		#print("google sign in signin with firebase body response: ", JSON.stringify(body.get_string_from_utf8()))
		#if response_code == 200:
			#print("firebase auth response: ", JSON.stringify(body.get_string_from_utf8()))
			#var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
			#if response.has("idToken"):
				#var username: String = ""
				#if response.has("displayName"):
					#username = response.displayName
				#HttpNetworkManager.request_http_firebase_auth(response.idToken, username)
				#auth_active_timer.stop()
			#else:
				#SignalManager.emit_notice_signal("Issue With Google Signin")
				#sign_out()
				#SignalManager.emit_open_loading_screen_signal(false)
			#
		#else:
			#SignalManager.emit_notice_signal("Issue With Google Signin")
			#print("Issue With Google Signin")
			#sign_out()
			#SignalManager.emit_open_loading_screen_signal(false)
	#)
	#http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))
