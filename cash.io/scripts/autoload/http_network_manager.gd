extends Node

var firebase_auth_http_request_node: HTTPRequest
var device_id_auth_http_request_node:HTTPRequest
var user_data_http_request_node: HTTPRequest
var list_rooms_http_request_node: HTTPRequest
var deposit_http_request_node: HTTPRequest
var withdrawal_check_http_request_node: HTTPRequest
var withdrawal_http_request_node: HTTPRequest

const SERVER_IP: String = "simplyludo.com"
const SERVER_PORT: int = 443
const DEVICE_ID_AUTH_API: String = "/auth/device/authenticate"
const FIREBASE_AUTH_API: String = "/auth/firebase/authenticate"
const SOCIAL_AUTHENTICATE_API: String = "/auth/social/authenticate"
const GET_ROOMS_API: String = "/rooms"
const GET_USER_DATA_API: String = "/users/me?fields=username,email,wallet,userid"
const MAKE_PAYMENT_API: String = "/payments/deposit"
const CREATE_DEPOSIT_API: String = "/payments/deposits/create"
const WITHDRAWAL_REQUEST_API: String = "/payments/withdrawals/create"
const WITHDRAWAL_CHECK_ACCOUNT_API: String = "/payments/withdrawals/account-status"

var device_id: String = ""
var authenticate_access_token: String = ""

var current_payment_provider: String = ""
var current_payment_amount: int = 0
var attempted_silent_auth: bool = false


var user_data_request_timeout_timer: Timer = Timer.new()
var list_room_request_timeout_timer: Timer = Timer.new()

func _ready() -> void:
	configure_timer()
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.websocket_disconnected.connect(_on_websocket_disconnected)
	SignalManager.signout_successful.connect(_on_signout_successful)
	get_device_id()
	set_process(false)

func configure_timer() -> void:
	add_child(user_data_request_timeout_timer)
	add_child(list_room_request_timeout_timer)
	user_data_request_timeout_timer.one_shot = true
	user_data_request_timeout_timer.wait_time = 60
	list_room_request_timeout_timer.wait_time = 60
	user_data_request_timeout_timer.timeout.connect(func():
		list_room_request_timeout_timer.stop()
		SignalManager.emit_error_getting_user_data_signal()
		SignalManager.emit_notice_signal("Issue Getting Player Data")
		SignalManager.emit_open_loading_screen_signal(false)
	)
	list_room_request_timeout_timer.timeout.connect(func():
		user_data_request_timeout_timer.stop()
		SignalManager.emit_error_getting_user_data_signal()
		SignalManager.emit_notice_signal("Issue Getting Room List")
		SignalManager.emit_open_loading_screen_signal(false)
	)

func get_device_id() -> void:
	if OS.get_name() != "Web":
		device_id = OS.get_unique_id()

#function tries to silent login using nakama and local saved data
func try_silent_auth() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	request_http_device_id_auth()
	attempted_silent_auth = true

#func set_request_token(token: String) -> void:
	#authenticate_access_token = token
	#print("auth successful")
	#request_http_user_data()

func request_social_auth(access_token: String) -> void:
	print("trying social auth, here is the trial id: ", access_token)
	SignalManager.emit_open_loading_screen_signal(true)
	if not firebase_auth_http_request_node:
		firebase_auth_http_request_node = HTTPRequest.new()
		add_child(firebase_auth_http_request_node)
		firebase_auth_http_request_node.request_completed.connect(_on_auth_http_request_node_request_completed)
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT)  + SOCIAL_AUTHENTICATE_API
	print("social auth url: ", url)
	var request_body: Dictionary = {
		"token": "",
		"device_id": ""
	}
	if OS.get_name() == "Web":
		request_body = {
			"token": access_token
		}
	else:
		request_body = {
			"token": access_token,
			"device_id": device_id
		}
	var headers : PackedStringArray = ["Content-Type: application/json"]
	firebase_auth_http_request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))

func request_http_firebase_auth(id_token: String, username: String) -> void:
	print("trying firebase auth, here is the trial id: ", id_token)
	SignalManager.emit_open_loading_screen_signal(true)
	if not firebase_auth_http_request_node:
		firebase_auth_http_request_node = HTTPRequest.new()
		add_child(firebase_auth_http_request_node)
		firebase_auth_http_request_node.request_completed.connect(_on_auth_http_request_node_request_completed)
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT)  + FIREBASE_AUTH_API
	var request_body: Dictionary = {
		"token": id_token,
		"username": username,
		"device_id": device_id
	}
	var headers : PackedStringArray = ["Content-Type: application/json"]
	firebase_auth_http_request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))

func request_http_device_id_auth() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if not device_id_auth_http_request_node:
		device_id_auth_http_request_node = HTTPRequest.new()
		add_child(device_id_auth_http_request_node)
		device_id_auth_http_request_node.request_completed.connect(_on_auth_http_request_node_request_completed)
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + DEVICE_ID_AUTH_API
	var headers : PackedStringArray = ["Content-Type: application/json"]
	var request_body: Dictionary = {"device_id": device_id}
	device_id_auth_http_request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))

func request_http_user_data() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	print("making request for user data, token is: ", authenticate_access_token)
	if not user_data_http_request_node:
		user_data_http_request_node = HTTPRequest.new()
		add_child(user_data_http_request_node)
		user_data_http_request_node.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			if response_code == 200:
				var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
				print("user http request data: ", response)
				var result_data: Dictionary = {
					"username": "",
					"wallet_balance": 0,
				}
				if response.has("username"):
					result_data.username = response.username
				if response.has("wallet_balance"):
					result_data.wallet_balance = response.wallet_balance
				if response.has("user_id"):
					GameHttpNetworkManager.set_current_player_id(response.user_id)
				SignalManager.emit_player_data_loaded_successfully_signal(result_data)
				user_data_request_timeout_timer.stop()
				request_http_room_list()
			else:
				SignalManager.emit_notice_signal("Issue loading player data")
				SignalManager.emit_error_getting_user_data_signal()
				SignalManager.emit_open_loading_screen_signal(false)
	)
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + GET_USER_DATA_API
	var headers : PackedStringArray = ["Authorization: Bearer " + authenticate_access_token, "Content-Type: application/json"]
	user_data_http_request_node.request(url, headers, HTTPClient.METHOD_GET)
	user_data_request_timeout_timer.start()

func request_http_room_list() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if not list_rooms_http_request_node:
		list_rooms_http_request_node = HTTPRequest.new()
		add_child(list_rooms_http_request_node)
		list_rooms_http_request_node.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			list_room_request_timeout_timer.stop()
			if response_code == 200:
				var response: Array = JSON.parse_string(body.get_string_from_utf8())
				var response_data: Dictionary = {
					"rooms": []
				}
				print("rooms loaded: ", response)
				response_data.rooms = response
				SignalManager.emit_all_rooms_loaded_signal(response_data)
				WebsocketMultiplayerRouter.connect_to_online_websocket_server(authenticate_access_token)
			else:
				SignalManager.emit_error_getting_user_data_signal()
				SignalManager.emit_notice_signal("Issue Getting Room List")
				SignalManager.emit_open_loading_screen_signal(false)
		)
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + GET_ROOMS_API
	print("room request url: ", url)
	var headers : PackedStringArray = ["Authorization: Bearer " + authenticate_access_token, "Content-Type: application/json"]
	list_rooms_http_request_node.request(url, headers, HTTPClient.METHOD_GET)
	list_room_request_timeout_timer.start()

func request_http_deposit() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if not deposit_http_request_node:
		deposit_http_request_node = HTTPRequest.new()
		add_child(deposit_http_request_node)
		deposit_http_request_node.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			if response_code == 200:
				var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
				if response.has("checkout_url"):
					OS.shell_open(response.checkout_url)
			else:
				#SignalManager.emit_deposit_request_failed_signal()
				SignalManager.emit_open_loading_screen_signal(false)
		)
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + CREATE_DEPOSIT_API
	var headers : PackedStringArray = ["Authorization: Bearer " + authenticate_access_token, "Content-Type: application/json"]
	var request_body: Dictionary =   {
		"provider": current_payment_provider,
		"amount_minor": current_payment_amount,
		}
	print("making http deposit request")
	deposit_http_request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))

func request_http_check_withdrawal() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if not withdrawal_check_http_request_node:
		withdrawal_check_http_request_node = HTTPRequest.new()
		add_child(withdrawal_check_http_request_node)
		withdrawal_check_http_request_node.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			print("withdrawal response code: ", response_code)
			print("withdrawal response body: " + str(JSON.parse_string(body.get_string_from_utf8())))
			#SignalManager.emit_withdrawal_form_prompt_signal()
			SignalManager.emit_open_loading_screen_signal(false)
			if response_code == 404:
				SignalManager.emit_withdrawal_form_prompt_signal()
			elif response_code == 204:
				SignalManager.emit_withdrawal_data_prompt_signal()
			else:
				SignalManager.emit_notice_signal("Error attempting withdrawal")
	)
	var url : String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + WITHDRAWAL_CHECK_ACCOUNT_API
	var headers : PackedStringArray = ["Authorization: Bearer " + authenticate_access_token, "Content-Type: application/json"]
	withdrawal_check_http_request_node.request(url, headers, HTTPClient.METHOD_GET)

func request_http_withdrawal(request_data: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	print("requesting withdrawal")
	if not withdrawal_http_request_node:
		withdrawal_http_request_node = HTTPRequest.new()
		add_child(withdrawal_http_request_node)
		withdrawal_http_request_node.request_completed.connect(func(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
			print("withdrawal response code: ", response_code)
			print("withdrawal response body: ", JSON.parse_string(body.get_string_from_utf8()))
			SignalManager.emit_open_loading_screen_signal(false)
			if response_code == 204:
				SignalManager.emit_notice_signal("Withdrawal Successful")
				#SignalManager.emit_withdrawal_successful_signal()
				#request_http_user_data()
				##emit the signal to open withdrawal in progress here
			else:
				SignalManager.emit_notice_signal("Issue with withdrawal, try again")
		)
	var url : String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + WITHDRAWAL_REQUEST_API
	var headers : PackedStringArray = ["Authorization: Bearer " + authenticate_access_token, "Content-Type: application/json"]
	withdrawal_http_request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_data))

func request_payment() -> void:
	var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + MAKE_PAYMENT_API
	OS.shell_open(url)

func get_current_payment_provider() -> String:
	return current_payment_provider

func set_current_payment_provider_to_opay() -> void:
	current_payment_provider = "opay"

func set_current_payment_provider_to_coinremitter() -> void:
	current_payment_provider = "coinremitter"

func set_current_payment_amount(amount: int) -> void:
	current_payment_amount = amount

func check_if_payment_provider_is_opay() -> bool:
	if current_payment_provider == "opay":
		return true
	return false

func check_if_payment_provider_is_coinremitter() -> bool:
	if current_payment_provider == "coinremitter":
		return true
	return false

func _on_signout_successful() -> void:
	authenticate_access_token = ""

func _on_reset_game_signal() -> void:
	request_http_user_data()
	request_http_room_list()

func _on_auth_http_request_node_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("social/device id auth result: ", result)
	print("social/device id auth response code: ", response_code)
	print("social/device id auth response data: ", JSON.parse_string(body.get_string_from_utf8()))
	if response_code == 200:
		var response: Dictionary = JSON.parse_string(body.get_string_from_utf8())
		if response.has("access_token"):
			authenticate_access_token = response.access_token
			
			#WebsocketMultiplayerRouter.set_authentication_access_token(response.access_token)
			GlobalManager.set_can_silent_auth_user_data(true)
		print("auth successful")
		request_http_user_data()
	else:
		SignalManager.emit_open_loading_screen_signal(false)
		if attempted_silent_auth == false:
			SignalManager.emit_notice_signal("Issue authenticating")
		if attempted_silent_auth == true:
			attempted_silent_auth = false

func _on_websocket_disconnected() -> void:
	set_process(false)
