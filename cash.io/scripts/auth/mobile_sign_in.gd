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
const GOOGLE_CONNECTION_NAME: String = "google-oauth2"
const APPLE_CONNECTION_NAME: String = "apple"


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

func google_sign_in() -> void:
	print("signin clicked")
	var post_load : String = AUTHORIZATION_URL + "?" + \
	"client_id=" + OAUTH_CLIENT_ID + "&response_type=code" + "&redirect_uri=" + MOBILE_REDIRECT_URI + \
	"&audience=" + API_AUDIENCE + "&scope=openid%20profile%20email" + "&code_challenge=" + \
	code_challenge + "&code_challenge_method=S256" + "&state=" + STATE + "&connection=" + GOOGLE_CONNECTION_NAME
	start_signin_process(post_load)


func ios_sign_in() -> void:
	print("signin clicked")
	var post_load : String = AUTHORIZATION_URL + "?" + \
	"client_id=" + OAUTH_CLIENT_ID + "&response_type=code" + "&redirect_uri=" + MOBILE_REDIRECT_URI + \
	"&audience=" + API_AUDIENCE + "&scope=openid%20profile%20email" + "&code_challenge=" + \
	code_challenge + "&code_challenge_method=S256" + "&state=" + STATE + "&connection=" + APPLE_CONNECTION_NAME
	start_signin_process(post_load)

func start_signin_process(post_load: String) -> void:
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
	if OS.get_name() == "Android":
		OS.shell_open(post_load)
	elif OS.get_name() == "iOS":
		OS.execute("open", [post_load])

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
