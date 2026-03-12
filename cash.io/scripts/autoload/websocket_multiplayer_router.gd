extends Node

const SERVER_IP: String = "simplyludo.com"
const SERVER_PORT: int = 443

const WEBSOCKET_ONLINE_API: String = "/ws-session"

var websocket_client: WebSocketPeer = WebSocketPeer.new()
const WEBSOCKET_SERVER = "/rooms/join"
var last_websocket_state: WebSocketPeer.State = WebSocketPeer.STATE_OPEN
var websocket_speed_configured: bool = false
var started_game: bool = false
var websocket_can_function: bool = false
var websocket_connection_is_poor: bool = false

const WEBSOCKET_SERVER_FRAME_TICK: float = 1.0/100.0#1.0/30.0
const WEBSOCKET_SERVER_PING_FRAME_TICK: float = 1.0/5.0
var websocket_tick_count: float = 0
var websocket_ping_count: float = 0
var last_websocket_room_id: String = ""
enum WEBSOCKET_SERVER_STATE{DISCONNECTED, CONNECTION, WAITING_TO_REJOIN}
var current_websocket_server_state: WEBSOCKET_SERVER_STATE = WEBSOCKET_SERVER_STATE.DISCONNECTED
const WEBSOCKET_MAX_COUNT_TO_DETECT_NO_DATA_FROM_SERVER: float = 5
var websocket_count_to_detect_no_data_from_server: float = 0

var websocket_disconnected: bool = false
var authenticate_access_token: String = ""


func _ready() -> void:
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.signout_successful.connect(_on_signout_successful)

	set_process(false)

func set_authentication_access_token(value: String) -> void:
	authenticate_access_token = value

func connect_to_online_websocket_server(access_token: String) -> void:
	authenticate_access_token = access_token
	print("access token: ", access_token)
	SignalManager.emit_open_loading_screen_signal(true)
	var url: String = "wss://" + SERVER_IP + WEBSOCKET_ONLINE_API + "?token=" + authenticate_access_token
	websocket_server(url)

func reconnect_to_online_websocket_server() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	var url: String = "wss://" + SERVER_IP + WEBSOCKET_ONLINE_API + "?token=" + authenticate_access_token
	websocket_server(url)

#func start_websocket_server(room_id: String = "") -> void:
	#if websocket_client.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		#websocket_client.close(-1)
	#_on_reset_game_signal()
	#last_websocket_room_id = room_id
	#SignalManager.emit_open_loading_screen_signal(true)
	#var url: String = "wss://" + SERVER_IP  + WEBSOCKET_SERVER + "?" + "room_id=" + room_id + "&token=" + authenticate_access_token
	#websocket_server(url)
	#current_websocket_server_state = WEBSOCKET_SERVER_STATE.CONNECTION
#
#func reconnect_websocket_server() -> void:
	#if websocket_client.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		#websocket_client.close(-1)
	#websocket_can_function = true
	#websocket_disconnected = false
	#print("trying to reconnect, with last room id: ", last_websocket_room_id)
	#print("websocket client state: ", websocket_client.get_ready_state())
	#SignalManager.emit_open_loading_screen_signal(true)
	#var url: String = "wss://" + SERVER_IP  + WEBSOCKET_SERVER + "?" + "room_id=" + last_websocket_room_id + "&token=" + authenticate_access_token + "&rejoin=true"
	#websocket_server(url)

func websocket_server(url: String = "") -> void:
	websocket_client.inbound_buffer_size = 2000000
	#print("testing websocket server: ", url)
	#print("is websocket client valid: ", websocket_client)
	#print("what is websocket client ready state: ", websocket_client.get_ready_state())
	if websocket_client and websocket_client.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		print("url: ", url)
		var status: Error = websocket_client.connect_to_url(url)
		#print("connecting to server")
		print(websocket_client.get_ready_state())
		if status != OK:
			#print("issue starting websocket client")
			SignalManager.emit_websocket_disconnected_signal()
			SignalManager.emit_notice_signal("Issue connecting to server")
		else:
			#print("websocket request was successful", websocket_client.get_ready_state())
			set_process(true)
	else:
		SignalManager.emit_open_loading_screen_signal(false)

func set_websocket_speed() -> void:
	if not websocket_speed_configured:
		websocket_client.set_no_delay(true)
		websocket_speed_configured = true
		current_websocket_server_state = WEBSOCKET_SERVER_STATE.CONNECTION
		print("first connection detected in websocket")
	pass

func check_first_message_on_websocket(message: Dictionary) -> void:
	if message:
		if started_game == false:
			started_game = true
			SignalManager.emit_open_loading_screen_signal(false)
			SignalManager.emit_startup_request_data_loaded_successfully()

func close_websocket_client():
	if websocket_client:
		if websocket_client.get_ready_state() == WebSocketPeer.STATE_OPEN:
			current_websocket_server_state = WEBSOCKET_SERVER_STATE.DISCONNECTED
			websocket_client.close(-1)
			set_process(false)

func server_tick_look_up(delta: float) -> bool:
	if not websocket_tick_count > WEBSOCKET_SERVER_FRAME_TICK:
		websocket_tick_count += delta
		websocket_can_function = false
		return false
	else:
		websocket_tick_count = 0
		websocket_can_function = true
		return true

func _process(delta: float) -> void:
	if server_tick_look_up(delta):
		
		websocket_client.poll()
		#print("websocket is polling")
		var socket_state: WebSocketPeer.State = websocket_client.get_ready_state()
		if socket_state == WebSocketPeer.STATE_OPEN:
			print("websocket connection is open at: ", Time.get_unix_time_from_system())
			set_websocket_speed()
			if current_websocket_server_state == WEBSOCKET_SERVER_STATE.CONNECTION:
				websocket_send_server_ping(delta)
				websocket_connection_check(delta)
				websocket_read_data()
		elif socket_state == WebSocketPeer.STATE_CLOSED:
			print("websocket connection closed")
			print("websocket connection is closed at: ", Time.get_unix_time_from_system())
			if current_websocket_server_state == WEBSOCKET_SERVER_STATE.CONNECTION:
				var code: int = websocket_client.get_close_code()
				var reason: String = websocket_client.get_close_reason()
				print("websocket client disconnected from server with code: " + str(code) + " and reason: " + reason)
				SignalManager.emit_open_loading_screen_signal(false)
				SignalManager.emit_notice_signal("Game disconnected from server")
				SignalManager.emit_websocket_disconnected_signal()
				set_process(false)
				websocket_disconnected = true
				#set_process(false)
			#if current_websocket_server_state == WEBSOCKET_SERVER_STATE.DISCONNECTED:
				#set_process(false)
		#elif socket_state == WebSocketPeer.STATE_CLOSING:
			#print("websocket closing")

func websocket_send_server_ping(delta: float) -> void:
	if websocket_ping_count < WEBSOCKET_SERVER_PING_FRAME_TICK:
		websocket_ping_count += delta
	else:
		websocket_ping_count = 0
		GameHttpNetworkManager.send_ping()

func websocket_connection_check(delta: float) -> void:
	#print("matter")
	if websocket_client.get_available_packet_count() == 0:
		#print("websocket not sending packets")
		if current_websocket_server_state == WEBSOCKET_SERVER_STATE.CONNECTION:
			#print("websocket is still seeing connection")
			if websocket_count_to_detect_no_data_from_server < WEBSOCKET_MAX_COUNT_TO_DETECT_NO_DATA_FROM_SERVER:
				websocket_count_to_detect_no_data_from_server += delta
				#print("websocket counting to disabled")
			else:
				websocket_count_to_detect_no_data_from_server = 0
				SignalManager.emit_notice_signal("Check Internet Connection")
				websocket_connection_is_poor = true
				SignalManager.emit_websocket_connection_is_poor_signal(true)
				#SignalManager.emit_websocket_disconnected_signal()
				#set_process(false)
				#SignalManager.emit_open_loading_screen_signal(false)
				#websocket_disconnected = true

func websocket_read_data() -> void:
	while  websocket_client.get_available_packet_count() > 0:
		var packet: PackedByteArray = websocket_client.get_packet()
		var message: String = packet.get_string_from_utf8()
		if message != "":
			var readable_message: Dictionary = JSON.parse_string(message)
			#print("readable message: ", readable_message)
			if websocket_disconnected:
				websocket_disconnected = false
				SignalManager.emit_open_loading_screen_signal(false)
			check_first_message_on_websocket(readable_message)
			if websocket_connection_is_poor == true:
				websocket_connection_is_poor = false
				SignalManager.emit_websocket_connection_is_poor_signal(false)
			GameHttpNetworkManager.network_process(readable_message)
		if websocket_count_to_detect_no_data_from_server > 0:
			websocket_count_to_detect_no_data_from_server = 0

func send_important_data_on_websocket(payload: Dictionary) -> void:
	if websocket_client.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var data: PackedByteArray = JSON.stringify(payload).to_utf8_buffer()
		var data_sent_status: Error = websocket_client.send(data, WebSocketPeer.WRITE_MODE_TEXT)
		print("important data sent via websocket status: ", data_sent_status)

func send_data_on_websocket(payload: Dictionary) -> void:
	if websocket_can_function:
		if websocket_client.get_ready_state() == WebSocketPeer.STATE_OPEN:
			var data: PackedByteArray = JSON.stringify(payload).to_utf8_buffer()
			var data_sent_status: Error = websocket_client.send(data, WebSocketPeer.WRITE_MODE_TEXT)
			print("data sent via websocket status: ", data_sent_status)

func _on_reset_game_signal() -> void:
	websocket_speed_configured = false
	started_game = false
	websocket_can_function = true
	websocket_disconnected = false

func _on_signout_successful() -> void:
	set_authentication_access_token("")
