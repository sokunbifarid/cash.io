extends Node

const OAUTH_DOMAIN: String = "dev-nwibq0byvol7tlrj.us.auth0.com"
const OAUTH_CLIENT_ID: String = "Rcw5Sgav4iJ0vYTIA9UTUXKEXZvDeMOs"
const API_AUDIENCE: String = "urn:cashio:api"
const REDIRECT_URI: String = "http://localhost:8000/callback"

var code_verifier: String = ""
var code_challenge: String = ""
var auth_code: String = ""
var server : TCPServer = TCPServer.new()
const SERVER_PORT: int = 8000
var timeout_timer: Timer
var auth_is_active: bool = true
var AUTH_ACTIVE_DURATION: float = 120

func _ready() -> void:
	set_process(false)

func generate_code_verifier() -> String:
	var bytes = Crypto.new().generate_random_bytes(32)
	return Marshalls.raw_to_base64(bytes).replace("+","-").replace("/","_").replace("=","")

func generate_code_challenge(verifier:String) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())
	var hash = ctx.finish()
	return Marshalls.raw_to_base64(hash).replace("+","-").replace("/","_").replace("=","")

func sign_in() -> void:
	print("signin clicked")
	SignalManager.emit_open_loading_screen_signal(true)
	code_verifier = generate_code_verifier()
	code_challenge = generate_code_challenge(code_verifier)

	var state = str(randi()) + str(Time.get_ticks_usec())
	var auth_url = "https://%s/authorize?client_id=%s&response_type=code&redirect_uri=%s&scope=openid profile email&audience=%s&code_challenge=%s&code_challenge_method=S256&state=%s&connection=google-oauth2" % [
		OAUTH_DOMAIN, OAUTH_CLIENT_ID, REDIRECT_URI, API_AUDIENCE, code_challenge, state
	]

	server.listen(SERVER_PORT)
	OS.shell_open(auth_url)
	set_process(true)
	auth_is_active = true
	timeout_timer = Timer.new()
	add_child(timeout_timer)
	timeout_timer.one_shot = true
	timeout_timer.timeout.connect(_on_timeout_timer_timeout)
	timeout_timer.wait_time = AUTH_ACTIVE_DURATION
	timeout_timer.start()


func _process(delta: float) -> void:
	if auth_is_active and server.is_connection_available():
		var conn = server.take_connection()
		var request = conn.get_string(conn.get_available_bytes())
		var code = extract_code_from_request(request)
		print("code: ", code)
		if code != "":
			exchange_code_for_token(code)
		conn.put_data("HTTP/1.1 200 OK\r\n\r\nYou can close this window.".to_utf8_buffer())
		conn.disconnect_from_host()
		set_process(false)

func exchange_code_for_token(code: String) -> void:
	if auth_is_active:
		var url = "https://%s/oauth/token" % OAUTH_DOMAIN
		var body = {
			"grant_type": "authorization_code",
			"client_id": OAUTH_CLIENT_ID,
			"code": code,
			"redirect_uri": REDIRECT_URI,
			"code_verifier": code_verifier
		}
		var http = HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(func(result, response_code, headers, body_bytes):
			print("Response code:", response_code)
			timeout_timer.stop()
			if response_code == 200:
				var data = JSON.parse_string(body_bytes.get_string_from_utf8())
				if data.has("access_token"):
					var token = data.access_token
					HttpNetworkManager.request_social_auth(token)
			else:
				print("Auth failed:", body_bytes.get_string_from_utf8())
				SignalManager.emit_notice_signal("Issue Authenticating")
				SignalManager.emit_open_loading_screen_signal(false)
		)
		http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(body))

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
	server.stop()
	SignalManager.emit_open_loading_screen_signal(false)
	SignalManager.emit_notice_signal("Timeout")
