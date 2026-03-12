extends Node

var client : NakamaClient
var session : NakamaSession
var socket: NakamaSocket
var bridge: NakamaMultiplayerBridge
var current_active_match_id: String
var active_match_session: NakamaRTAPI.Match
var players_in_active_match_session: Dictionary = {}
var pellets_in_active_match_session: Dictionary = {}

var room_rpc_call_retries_count: int = 0
var user_profile_rpc_call_retries_count: int = 0
const MAX_RPC_CALL_RETRIES_COUNT: int = 3

const NAKAMA_ROOM_SERVER_SNAP_SHOT_OP_CODE: int = 2
const NAKAMA_CHARACTER_SERVER_MOVEMENT_SNAP_SHOT_OP_CODE: int = 1
const NAKAMA_REQUEST_CASHOUT_OP_CODE: int = 3
const SERVER_SCHEMA: String = "https"
const SERVER_KEY: String = "defaultkey"
const SERVER_IP: String = "simplyludo.com"#"92.205.187.214"
const SERVER_PORT: int = 443#7350
const GET_USER_PROFILE_API: String = "/get_user_profile"
const GET_ROOMS_API: String = "/get_rooms"


var silent_login_pass: String = OS.get_unique_id() + "10/01/001"
const SAVE_PATH_FOR_SESSION_SAVE: String = "user://nakama_session.save"

enum ALL_AUTH_TYPE{DEVICE, EMAIL_PASS, GOOGLE, APPLE}
var current_auth_type: ALL_AUTH_TYPE = ALL_AUTH_TYPE.DEVICE
var nakama_room_first_server_snap_shot: bool = false
var trying_to_silent_auth: bool = false

func _ready() -> void:
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)

#function tries to silent login using nakama and local saved data
func try_nakama_silent_auth() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	await get_tree().create_timer(2).timeout
	if FileAccess.file_exists(SAVE_PATH_FOR_SESSION_SAVE):
		trying_to_silent_auth = true
		print("token file for nakama exists")
		var token: FileAccess = FileAccess.open_encrypted_with_pass(SAVE_PATH_FOR_SESSION_SAVE, FileAccess.READ, silent_login_pass)
		if token:
			var data: Dictionary = JSON.parse_string(token.get_as_text())
			if data.has("token") and data.has("refresh_token"):
				client = Nakama.create_client(SERVER_KEY, SERVER_IP, SERVER_PORT, SERVER_SCHEMA)
				var temp_nakama_session: NakamaSession = NakamaSession.new(data.token, false, data.refresh_token)
				if data.has("auth_type"):
					current_auth_type = data.auth_type
				print("session trying to restore using token and refresh token")
				if not temp_nakama_session.is_expired():
					print("session was able to use token and refresh token")
					session = temp_nakama_session
					nakama_connect_to_web_socket_server()
					trying_to_silent_auth = false
					return
				else:
					print("session could not be restored with token, trying to refresh with refresh_token")
					await get_tree().create_timer(2.0).timeout
					temp_nakama_session = await client.session_refresh_async(temp_nakama_session)
					if not temp_nakama_session.is_expired():
						session = temp_nakama_session
						save_nakama_session_for_silent_auth(true) 
						nakama_connect_to_web_socket_server()
					else:
						SignalManager.emit_open_loading_screen_signal(false)
						trying_to_silent_auth = false
			else:
				SignalManager.emit_open_loading_screen_signal(false)
		else:
			printerr("issue with getting token file from saved file")
			trying_to_silent_auth = false
			SignalManager.emit_open_loading_screen_signal(false)
	else:
		trying_to_silent_auth = false
		SignalManager.emit_open_loading_screen_signal(false)

#function saves signin token and refresh token from nakama locally
func save_nakama_session_for_silent_auth(condition: bool, auth_type: ALL_AUTH_TYPE = ALL_AUTH_TYPE.EMAIL_PASS) -> void:
	if session:
		var file: FileAccess = FileAccess.open_encrypted_with_pass(SAVE_PATH_FOR_SESSION_SAVE, FileAccess.WRITE, silent_login_pass)
		current_auth_type = auth_type
		if file:
			var data: Dictionary = {"token": session.token, "refresh_token": session.refresh_token, "last_auth_type": auth_type}
			if condition:
				file.store_string(JSON.stringify(data))
			else:
				file.store_string(JSON.stringify({}))
			file.close()

#function is used to login user with nakama using google signin
func nakama_auth_user_from_google_sign_in(id_token: String, username: String, email: String) -> void:
	if trying_to_silent_auth == false:
		if not client:
			client = Nakama.create_client(SERVER_KEY, SERVER_IP, SERVER_PORT, SERVER_SCHEMA)
		session = await client.authenticate_google_async(id_token, username)
		if session.is_exception():
			print("issue with google login on nakama: ", session)
			SignalManager.emit_nakama_auth_user_with_google_worked_signal(false)
			SignalManager.emit_notice_signal(session.exception.message)
		else:
			print("nakama logged in google user")
			SignalManager.emit_nakama_auth_user_with_google_worked_signal(true)
			save_nakama_session_for_silent_auth(true, ALL_AUTH_TYPE.GOOGLE)
			nakama_connect_to_web_socket_server()
			await client.update_account_async(session, username, email)

#function initiates web socket call to nakama
func nakama_connect_to_web_socket_server() -> void:
	if client:
		SignalManager.emit_open_loading_screen_signal(true)
		print("nakama client when connecting to web socket server: ", client)
		if not socket:
			socket = Nakama.create_socket_from(client)
		if not socket.is_connected_to_host():
			var connection : Variant = await socket.connect_async(session)
			if connection.is_exception():
				printerr("Issue with nakama startiing socket session: ", connection.exception)
				SignalManager.emit_notice_signal(connection.exception.message)
				force_signout()
				SignalManager.emit_open_loading_screen_signal(false)
			else:
				print("nakama socket was initialized successfully")
				if not socket.closed.is_connected(_on_nakama_web_socket_connection_closed):
					socket.closed.connect(_on_nakama_web_socket_connection_closed)
				call_all_required_on_load_rpc()
		else:
				call_all_required_on_load_rpc()
				SignalManager.emit_nakama_websocket_reconnected_signal()
	else:
		printerr("Nakama client not initialized before executing function nakama_connect_to_web_socket_server in Network Manager.gd")

#function is called to signout user from nakama
func nakama_auth_user_sign_out() -> void:
	var logout_result: NakamaAsyncResult = await client.session_logout_async(session)
	if logout_result.is_exception():
		SignalManager.emit_notice_signal(logout_result.exception.message)
		printerr("Nakama couldnt signout user")
	else:
		session = null
		print("Nakama signed out successfully")
		save_nakama_session_for_silent_auth(false)
		SignalManager.emit_signout_successful_signal()

#function forces signout when rpc calls couldnt be made or when silent login doesnt work and prompts user to signin/signup
func force_signout() -> void:
	if current_auth_type == ALL_AUTH_TYPE.DEVICE or current_auth_type == ALL_AUTH_TYPE.EMAIL_PASS:
		nakama_auth_user_sign_out()
	elif current_auth_type == ALL_AUTH_TYPE.GOOGLE:
		nakama_auth_user_sign_out()
		#GoogleSignIn.sign_out()
	elif current_auth_type == ALL_AUTH_TYPE.APPLE:
		nakama_auth_user_sign_out()
		#AppleSignIn.sign_out()

#to be used when signout button has been pressed, so that the game can keep track if nakama and google or apple has successfully sign out
func is_nakama_signed_out() -> bool:
	if session == null:
		return true
	return false

#function makes all rpc calls required to start the game
func call_all_required_on_load_rpc() -> void:
	room_rpc_call_retries_count = 0
	user_profile_rpc_call_retries_count = 0
	call_rpc_for_get_user_profile_api()
	call_rpc_for_get_rooms_api()

#function makes rpc call to get user profile
func call_rpc_for_get_user_profile_api() -> void:
	if session and client:
		user_profile_rpc_call_retries_count += 1
		SignalManager.emit_open_loading_screen_signal(true)
		var rpc_result: Variant = await client.rpc_async(session, GET_USER_PROFILE_API)
		if rpc_result.is_exception():
			print("calling the rpc for get use profile api throws an exception")
			if user_profile_rpc_call_retries_count < MAX_RPC_CALL_RETRIES_COUNT:
				call_rpc_for_get_user_profile_api()
			else:
				SignalManager.emit_notice_signal(rpc_result.exception.message)
				force_signout()
				SignalManager.emit_open_loading_screen_signal(false)
		else:
			print("rpc payload result from calling user profile: " + str(rpc_result.payload))
			var response: Dictionary = JSON.parse_string(rpc_result.payload)
			SignalManager.emit_nakama_loaded_player_profile_data_signal(response)
	else:
		printerr("session or client in nakama has not been initialized for get_user_profile_api")

#function makes rpc call to get the rooms from server
func call_rpc_for_get_rooms_api() -> void:
	if session and client:
		room_rpc_call_retries_count += 1
		SignalManager.emit_open_loading_screen_signal(true)
		var rpc_result: Variant = await client.rpc_async(session, GET_ROOMS_API)
		if rpc_result.is_exception():
			print("calling the rpc for get rooms api throws an exception: ", rpc_result.exception)
			if room_rpc_call_retries_count < MAX_RPC_CALL_RETRIES_COUNT:
				room_rpc_call_retries_count += 1
				call_rpc_for_get_rooms_api()
			else:
				SignalManager.emit_notice_signal(rpc_result.exception.message)
				force_signout()
				SignalManager.emit_open_loading_screen_signal(false)
		else:
			print("rpc payload result from calling rooms: " + str(rpc_result.payload))
			var response: Dictionary = JSON.parse_string(rpc_result.payload)
			SignalManager.emit_nakama_loaded_all_rooms_data_signal(response)
	else:
		printerr("session or client in nakama has not been initialized for get_rooms_api")

#function is called to join players to a room.
func join_room(match_id: String) -> void:
	if socket:
		SignalManager.emit_open_loading_screen_signal(true)
		if not socket.received_match_presence.is_connected(_on_nakama_received_match_presence):
			socket.received_match_presence.connect(_on_nakama_received_match_presence)
			socket.received_match_state.connect(self._on_received_match_state_data)
		active_match_session = await socket.join_match_async(match_id)
		
		if active_match_session.is_exception():
			print("Issue with nakama socket joining match: ", active_match_session.exception)
			SignalManager.emit_notice_signal(active_match_session.exception.message)
			SignalManager.emit_open_loading_screen_signal(false)
		else:
			print("joined match successfully and trying to spawn players")
			SignalManager.emit_prepare_game_signal()
			SignalManager.emit_open_loading_screen_signal(false)
			players_in_active_match_session.clear()
			current_active_match_id = match_id
	else:
		printerr("Nakama socket not initialized before trying to join room")

#function is called when player leaves the room, it is to be called on cashout
func leave_room() -> void:
	if socket and client:
		if active_match_session:
			SignalManager.emit_open_loading_screen_signal(true)
			active_match_session = null
			players_in_active_match_session.clear()
			current_active_match_id = ""
			await socket.leave_match_async(current_active_match_id)
			print("player left room")
			SignalManager.emit_nakama_left_room_successfully_signal()

#function gets the session id of the current player that is playing on the device
func get_authority_player_session_id() -> String:
	return active_match_session.self_user.session_id

#function updates dictionary that holds the list of players on the client side
func nakama_update_players_in_current_room(session_id: String, the_player: Node2D) -> void:
	players_in_active_match_session.set(session_id, the_player)

func nakama_update_pellets_in_current_room(id: String, the_pellet: Sprite2D) -> void:
	pellets_in_active_match_session.set(id, the_pellet)

#function is called to move the player
func nakama_send_movement_data(new_pos: Vector2) -> void:
	if client and socket:
		if socket.is_connected_to_host() and active_match_session:
			print("trying to send movement to nakama")
			var data_to_send: Dictionary = {"dx": new_pos.x, "dy": new_pos.y}
			socket.send_match_state_async(current_active_match_id, NAKAMA_CHARACTER_SERVER_MOVEMENT_SNAP_SHOT_OP_CODE, JSON.stringify(data_to_send))
			print("this was sent out successfully i guess")
		else:
			printerr("current player is not connected to host or not in a match session")
	else:
		printerr("socket or client not assigned when sending movement data")

func nakama_request_cashout() -> void:
	if client and socket:
		if socket.is_connected_to_host() and active_match_session:
			print("nakama trying to request cashout")
			await socket.send_match_state_async(current_active_match_id, NAKAMA_REQUEST_CASHOUT_OP_CODE, JSON.stringify(""))
			leave_room()
		else:
			printerr("current player is not connected to host or not in a match session")
	else:
		printerr("socket or client not assigned when requesting for cashout")

func nakama_update_all_players_position(players_updated: Array) -> void:
	for player: Dictionary in players_updated:
		if players_in_active_match_session.has(player.id):
			if players_in_active_match_session[player.id].is_inside_tree():
				if players_in_active_match_session[player.id].has_method("set_data"):
					players_in_active_match_session[player.id].set_data(Vector2(player.x, player.y), player.mass, player.coins, 0)

func nakama_update_all_pellets(pellets: Array) -> void:
	for pellet: Dictionary in pellets_in_active_match_session:
		if not pellets.has(pellet):
			pellets_in_active_match_session[pellet].queue_free()
			pellets_in_active_match_session.erase(pellet)

func load_data_on_join_match(pellets: Array, players: Array) -> void:
	SignalManager.emit_load_pellets_on_join_match_signal(pellets)
	for player: Dictionary in players:
		if players_in_active_match_session.has(player.id):
			if players_in_active_match_session[player.id].is_inside_tree():
				if players_in_active_match_session[player.id].has_method("set_data"):
					players_in_active_match_session[player.id].set_force_data(Vector2(player.x, player.y), player.mass, player.coins, player.color, player.name)

#function is called when the web socket disconnects
func _on_nakama_web_socket_connection_closed() -> void:
	SignalManager.emit_nakama_websocket_disconnected_signal()

#function is called when a player joins and leaves a server
func _on_nakama_received_match_presence(match_presence: NakamaRTAPI.MatchPresenceEvent) -> void:
	print("match presence received: ", match_presence)
	if match_presence.joins.size() > 0:
		for player_joined in match_presence.joins:
			if not players_in_active_match_session.has(player_joined.session_id):
				SignalManager.emit_player_connected_to_multiplayer_network_signal(player_joined.session_id)
				print("player joined a room match with session_id: ", player_joined.session_id)
	if match_presence.leaves.size() > 0:
		for player_left in match_presence.leaves:
			if players_in_active_match_session.has(player_left.session_id):
				print("player left a room match")
				players_in_active_match_session[player_left.session_id].queue_free()
				players_in_active_match_session.erase(player_left.session_id)

##function receives the match state from server and applies the position to the player
func _on_received_match_state_data(match_data: NakamaRTAPI.MatchData) -> void:
	print("match data: ", match_data)
	match match_data.op_code:
		NAKAMA_ROOM_SERVER_SNAP_SHOT_OP_CODE:
			var data: Dictionary = JSON.parse_string(match_data.data)
			var players: Array = []
			if nakama_room_first_server_snap_shot == false:
				nakama_room_first_server_snap_shot = true
				var pellets: Array = []
				if data.has("pellets"):
					pellets = data.pellets
				if data.has("players"):
					for entity: Dictionary in data.players:
						if entity.has("kind"):
							if entity["kind"] == "player":
								players.append(entity)
				load_data_on_join_match(pellets, players)

			elif data.has("players_updated"):
				nakama_update_all_players_position(data.players_updated)

			elif data.has("pellets"):
				nakama_update_all_pellets(data.pellets)

func _on_reset_game_signal() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	await get_tree().create_timer(0.2).timeout
	call_all_required_on_load_rpc()
