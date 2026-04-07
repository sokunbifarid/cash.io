extends ws_schema

var firebase_auth_http_request_node: HTTPRequest
var device_id_auth_http_request_node:HTTPRequest
#var user_data_http_request_node: HTTPRequest
#var list_rooms_http_request_node: HTTPRequest
#var deposit_http_request_node: HTTPRequest
#var withdrawal_check_http_request_node: HTTPRequest
#var withdrawal_http_request_node: HTTPRequest
#var set_skin_http_request_node: HTTPRequest
#var shop_http_request_node: HTTPRequest

const SERVER_IP: String = "playcash.io"#"simplyludo.com"
const SERVER_PORT: int = 443
const DEVICE_ID_AUTH_API: String = "/auth/device/authenticate"
const FIREBASE_AUTH_API: String = "/auth/firebase/authenticate"
const SOCIAL_AUTHENTICATE_API: String = "/auth/social/authenticate"
#const GET_ROOMS_API: String = "/rooms"
#const GET_USER_DATA_API: String = "/users/me?fields=username,email,wallet,userid,active_avatar,owned_avatars"
#const MAKE_PAYMENT_API: String = "/payments/deposit"
#const CREATE_DEPOSIT_API: String = "/payments/deposits/create"
#const WITHDRAWAL_REQUEST_API: String = "/payments/withdrawals/create"
#const WITHDRAWAL_CHECK_ACCOUNT_API: String = "/payments/withdrawals/account-status"
#const SET_SKIN_API: String = "/users/avatar"
#const SHOP_API: String = "/shop/catalog"

var device_id: String = ""
var authenticate_access_token: String = ""

var current_payment_provider: String = ""
var current_payment_amount: int = 0
var attempted_silent_auth: bool = false
var first_game_launch: bool = true

var user_data_request_timeout_timer: Timer = Timer.new()
var list_room_request_timeout_timer: Timer = Timer.new()
var shop_request_timeout_timer: Timer = Timer.new()

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
	add_child(shop_request_timeout_timer)
	user_data_request_timeout_timer.one_shot = true
	list_room_request_timeout_timer.one_shot = true
	shop_request_timeout_timer.one_shot = true
	user_data_request_timeout_timer.autostart = false
	list_room_request_timeout_timer.autostart = false
	shop_request_timeout_timer.autostart = false
	user_data_request_timeout_timer.wait_time = 60
	list_room_request_timeout_timer.wait_time = 60
	shop_request_timeout_timer.wait_time = 60
	user_data_request_timeout_timer.timeout.connect(func():
		list_room_request_timeout_timer.stop()
		SignalManager.emit_error_getting_user_data_signal()
		SignalManager.emit_notice_signal("Issue Getting Player Data")
		SignalManager.emit_open_loading_screen_signal(false)
	)
	list_room_request_timeout_timer.timeout.connect(func():
		list_room_request_timeout_timer.stop()
		SignalManager.emit_error_getting_user_data_signal()
		SignalManager.emit_notice_signal("Issue Getting Room List")
		SignalManager.emit_open_loading_screen_signal(false)
	)
	shop_request_timeout_timer.timeout.connect(func():
		shop_request_timeout_timer.stop()
		SignalManager.emit_error_getting_user_data_signal()
		SignalManager.emit_notice_signal("Issue Getting Shop Data")
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
#
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

#func request_http_firebase_auth(id_token: String, username: String) -> void:
	#print("trying firebase auth, here is the trial id: ", id_token)
	#SignalManager.emit_open_loading_screen_signal(true)
	#if not firebase_auth_http_request_node:
		#firebase_auth_http_request_node = HTTPRequest.new()
		#add_child(firebase_auth_http_request_node)
		#firebase_auth_http_request_node.request_completed.connect(_on_auth_http_request_node_request_completed)
	#var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT)  + FIREBASE_AUTH_API
	#var request_body: Dictionary = {
		#"token": id_token,
		#"username": username,
		#"device_id": device_id
	#}
	#var headers : PackedStringArray = ["Content-Type: application/json"]
	#firebase_auth_http_request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))

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
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.GET_ME
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)

func request_http_room_list() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.GET_ROOMS
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)

func request_http_shop() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.GET_SHOP_CATALOG
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)

func request_http_deposit() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.DEPOSITS_CREATE
	var create_deposit: CreateDepositBody = CreateDepositBody.new()
	create_deposit.provider = current_payment_provider
	create_deposit.amount_minor = current_payment_amount
	envelope.create_deposit_body = create_deposit
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)


func request_http_check_withdrawal() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.WITHDRAWALS_ACCOUNT_STATUS
	var check_body: StringBody = StringBody.new()
	check_body.value = get_current_payment_provider()
	print("payment provider: ", get_current_payment_provider())
	envelope.string_body = check_body
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	print("checking withdrawal")

func request_http_withdrawal(request_data: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	print("requesting withdrawal")
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.WITHDRAWALS_CREATE
	var create_withdrawal: CreateWithdrawalBody = CreateWithdrawalBody.new()
	create_withdrawal.provider = current_payment_provider
	if request_data.has("amount_minor"):
		create_withdrawal.amount_minor = request_data.amount_minor
	if check_if_payment_provider_is_coinremitter():
		if request_data.has("crypto_address"):
			create_withdrawal.crypto_address = request_data.crypto_address
	elif check_if_payment_provider_is_opay():
		var create_withdrawal_bank_details: WithdrawalBankDetailsBody = WithdrawalBankDetailsBody.new()
		if request_data.has("bank_details"):
			if request_data.bank_details.has("account_name"):
				create_withdrawal_bank_details.account_name = request_data.bank_details.account_name
			if request_data.bank_details.has("account_number"):
				create_withdrawal_bank_details.account_number = request_data.bank_details.account_number
			if request_data.bank_details.has("bank_name"):
				create_withdrawal_bank_details.bank_name = request_data.bank_details.bank_name
		create_withdrawal.bank_details = create_withdrawal_bank_details
	envelope.create_withdrawal_body = create_withdrawal
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)

#func request_payment() -> void:
	#var url: String = "https://" + SERVER_IP + ":" + str(SERVER_PORT) + MAKE_PAYMENT_API
	#if OS.get_name() == "iOS" or OS.get_name() == "macOS":
		#OS.execute("open", [url])
	#else:
		#OS.shell_open(url)

func request_append_user_selected_skin(skin_id: String) -> void:
	if skin_id != "":
		SignalManager.emit_open_loading_screen_signal(true)
		print("selecting skin: ", skin_id)
		var envelope: Envelope = Envelope.new()
		envelope.topic = Topic.SET_AVATAR
		var avatar_to_select_body: SetAvatarBody = SetAvatarBody.new()
		avatar_to_select_body.avatar = skin_id
		envelope.set_avatar_body = avatar_to_select_body
		WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	else:
		SignalManager.emit_notice_signal("Issue with selected skin")

func request_shop_item_purchase(id: String = "") -> void:
	if id != "":
		SignalManager.emit_open_loading_screen_signal(true)
		print("trying to purhchase store item")
		var envelope: Envelope = Envelope.new()
		envelope.topic = Topic.BUY_CATALOG_ITEM
		var catalogue_item_to_buy: BuyCatalogItemBody = BuyCatalogItemBody.new()
		catalogue_item_to_buy.item_id = id
		envelope.buy_catalog_item_body = catalogue_item_to_buy
		WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	else:
		SignalManager.emit_notice_signal("Item does not exist")

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
			GlobalManager.set_can_silent_auth_user_data(true)
		print("auth successful")
		WebsocketMultiplayerRouter.connect_to_online_websocket_server(authenticate_access_token)
	else:
		SignalManager.emit_open_loading_screen_signal(false)
		if attempted_silent_auth == false:
			SignalManager.emit_notice_signal("Issue authenticating")
		if attempted_silent_auth == true:
			attempted_silent_auth = false

func _on_websocket_disconnected() -> void:
	set_process(false)
