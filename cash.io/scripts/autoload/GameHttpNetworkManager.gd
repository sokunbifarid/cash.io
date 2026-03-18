extends Node

var current_player_list: Dictionary = {}
var current_pellets_list: Dictionary = {}
var current_player_id: String = ""
var player_starting_time: float = 0
var player_running_time: float = 0
var last_room_id: String = ""
const MAX_NUMBER_OF_RETRIES_TO_JOIN_ROOM: int = 3
var can_auto_join_room_on_launch: bool = true
var populate_pellets_list_basket_pellets: Array = []
var populate_player_list_basket_players: Array = []
var room_bound: Vector2 = Vector2.ZERO

func _ready() -> void:
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.prepare_game_for_play_again_signal.connect(_on_prepare_game_for_play_again_signal)
	SignalManager.match_over_signal.connect(_on_match_over_signal)

func _on_match_over_signal() -> void:
	player_starting_time = 0
	player_running_time = 0

func _on_prepare_game_for_play_again_signal() -> void:
	current_pellets_list = {}
	current_player_list = {}
	player_starting_time = 0
	player_running_time = 0

func _on_reset_game_signal() -> void:
	current_player_id = ""
	current_pellets_list = {}
	current_player_list = {}
	player_starting_time = 0
	player_running_time = 0
	last_room_id = ""

func network_process(payload: Dictionary) -> void:
	map_networked_payload(payload)
	#print("websocket server reply payload: ", payload)

func get_current_player_id() -> String:
	return current_player_id

func set_current_player_id(value: String) -> void:
	current_player_id = value

func map_networked_payload(payload: Dictionary) -> void:
	if payload.has("topic"):
		var payload_topic: String = payload.topic
		match payload_topic:
			"session.connected":
				append_session_connected_data(payload)
			"gateway.error":
				append_gateway_error_data(payload)
			"rooms.joined":
				append_room_joined_data(payload)
			"rooms.snapshot":
				append_snapshot_data(payload)
			"rooms.player_settled":
				append_player_settled_data(payload)
			"rooms.player_eliminated":
				append_player_eliminated_data(payload)
			"rooms.cashout_rejected":
				append_cashout_rejected_data(payload)
			"wallet.updated":
				append_wallet_updated_data(payload)
			"wallet.settlement_failed":
				append_wallet_settlement_failed_data(payload)

func append_session_connected_data(_payload: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(false)
	print("session connected")
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.AUTH:
		if can_auto_join_room_on_launch == false:
			SignalManager.emit_startup_request_data_loaded_successfully()
		else:
			send_join_room(GlobalManager.get_last_match_room_id())
	elif GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		print("can auto join room is true")
		if GlobalManager.get_was_in_match():
			print("detected player was in a match previously")
			SignalManager.emit_websocket_reconnected_signal()
			send_join_room(GlobalManager.get_last_match_room_id())
			print("trying to join last match")
		else:
			print("detected player was not in match previously")
			#SignalManager.emit_startup_request_data_loaded_successfully()
	else:
		SignalManager.emit_websocket_reconnected_signal()

func append_gateway_error_data(payload: Dictionary) -> void:
	if payload.has("payload"):
		if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_ROOMS:
			if payload.payload.has("message"):
				if payload.payload.message == "rejoin_not_available" or payload.payload.message == "room_not_joined":
					GlobalManager.set_was_in_match(false, "")
					send_join_room(last_room_id)
				elif payload.payload.message == "room_already_joined" or payload.payload.message == "use_rejoin":
					GlobalManager.set_was_in_match(true, last_room_id)
					send_join_room(last_room_id)
				elif payload.payload.message == "invalid_join_payload" or payload.payload.message == "invalid_room_id" or payload.payload.message == "user_not_found":
					SignalManager.emit_open_loading_screen_signal(false)
					SignalManager.emit_notice_signal("Issue Joining Room")
					#print("appending gateway error, " + payload.payload.message)
				elif payload.payload.message == "room_not_found" or payload.payload.message == "room_not_active" or payload.payload.message =="insufficient_wallet_balance" or payload.payload.message == "join_stake_debit_failed" or payload.payload.message == "room_unavailable" or payload.payload.message == "room_full" or payload.payload.message == "":
					SignalManager.emit_open_loading_screen_signal(false)
					#print("appending gateway error, " + payload.payload.message)
					SignalManager.emit_notice_signal(payload.payload.message)


func append_room_joined_data(payload: Dictionary) -> void:
	print("room joined data: ", payload)
	if payload.has("payload"):
		if payload.payload.has("remaining_sec"):
			player_starting_time = payload.payload.remaining_sec
		if payload.payload.has("pellets"):
			if payload.payload.pellets.size() > 0:
				populate_pellets_list(payload.payload.pellets)
		if payload.payload.has("players"):
			if payload.payload.players.size() > 0:
				populate_player_list(payload.payload)
		if payload.payload.has("remaining_sec") or payload.payload.has("pellets") or payload.payload.has("players"):
			SignalManager.emit_open_loading_screen_signal(false)
			GlobalManager.set_was_in_match(true, last_room_id)
			SignalManager.emit_prepare_game_signal()
		GlobalManager.current_game_state = GlobalManager.GAME_STATE.BUBBLE_GAME

func append_snapshot_data(payload: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(false)
	if payload.has("payload"):
		if payload.payload.has("bounds"):
			room_bound = Vector2(payload.bounds.width, payload.bounds.height)
		if payload.payload.has("updated_players"):
			if payload.payload.updated_players.size() > 0:
				update_players(payload.payload.updated_players)
		if payload.payload.has("spawned_players"):
			if payload.payload.spawned_players.size() > 0:
				populate_player_list(payload.payload)
		if payload.payload.has("removed_players"):
			if payload.payload.removed_players.size() > 0:
				remove_eaten_players(payload.payload.removed_players)
		if payload.payload.has("spawned_pellets"):
			if payload.payload.spawned_pellets.size() > 0:
				spawned_pellets(payload.payload.spawned_pellets)
		if payload.payload.has("removed_pellets"):
			if payload.payload.removed_pellets.size() > 0:
				remove_eaten_pellets(payload.payload.removed_pellets)
		if payload.payload.has("remaining_sec"):
			player_running_time = payload.payload.remaining_sec

func append_player_settled_data(payload: Dictionary) -> void:
	#print("trying to append player_settled_data: ", payload)
	var data: Dictionary = {"coins": 0}
	GlobalManager.set_was_in_match(false, "")
	if payload.has("payload"):
		if payload.payload.has("coins"):
			data.coins = payload.payload.coins
	SignalManager.emit_match_over_signal(data, true)

func append_player_eliminated_data(_payload: Dictionary) -> void:
	SignalManager.emit_match_over_signal({}, false)

func append_cashout_rejected_data(payload: Dictionary) -> void:
	#print("cashout rejected: ", payload)
	if payload.has("payload"):
		if payload.payload.has("wait_ms"):
			SignalManager.emit_cashout_rejected_signal(payload.payload.wait_ms)

func append_wallet_updated_data(payload: Dictionary) -> void:
	#print("wallet updated: ", payload)
	if payload.has("payload"):
		if payload.payload.has("amount"):
			#print("appending wallet updated data")
			SignalManager.emit_wallet_updated_successfull_signal(int(payload.payload.amount))
			SignalManager.emit_open_loading_screen_signal(false)

func append_wallet_settlement_failed_data(payload: Dictionary) -> void:
	#print("wallet settlement failed: ", payload)
	if payload.has("detail"):
		SignalManager.emit_wallet_settlement_failed_signal(payload.detail)

func spawned_pellets(payload: Array) -> void:
	#print("spawned pellets: ", payload)
	populate_pellets_list(payload)

func populate_player_list(payload: Dictionary) -> void:
	populate_player_list_basket_players = []
	var temp_player_list: Array = []
	if payload.has("bounds"):
		room_bound = Vector2(payload.bounds.width, payload.bounds.height)
	if payload.has("players"):
		temp_player_list = payload.players
	elif payload.has("spawned_players"):
		temp_player_list = payload.spawned_players
	if temp_player_list.size() > 0:
		for i: Dictionary in temp_player_list:
			if i.has("id"):
				if not current_player_list.has(i.id):
					populate_player_list_basket_players.append(i)
		if populate_player_list_basket_players.size() > 0:
			SignalManager.emit_load_players_on_join_match_signal(populate_player_list_basket_players, room_bound)

func populate_pellets_list(payload: Array) -> void:
	print("populating pellets list: ", payload)
	populate_pellets_list_basket_pellets = []
	for i: Dictionary in payload:
		if i.has("id"):
			if not current_pellets_list.has(i.id):
				populate_pellets_list_basket_pellets.append(i)
	if populate_pellets_list_basket_pellets.size() > 0:
		SignalManager.emit_load_pellets_on_join_match_signal(populate_pellets_list_basket_pellets)

func update_players(payload: Array) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		for i: Dictionary in payload:
			if i.has("id"):
				if current_player_list.has(i.id):
					var new_pos: Vector2 = Vector2.ZERO
					var coin: int = 0
					var mass: int = 0
					var input_sequence: int = 0
					if i.has("x") and i.has("y"):
						new_pos = Vector2(i.x, i.y)
					if i.has("coins"):
						coin = i.coins
					if i.has("mass"):
						mass = i.mass
					if i.has("input_sequence"):
						input_sequence = i.input_sequence
					current_player_list[i.id].set_data(new_pos, mass, coin, input_sequence)

func remove_eaten_players(payload: Array) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		print("remove eaten players payload: ", payload)
		for i: String in payload:
			if current_player_list.has(i):
				current_player_list[i].character_disabled()
				current_player_list.erase(i)

func remove_eaten_pellets(payload: Array) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		print("remove eaten pellets payload: ", payload)
		for i: String in payload:
			if current_pellets_list.has(i):
				current_pellets_list[i].queue_free()
				current_pellets_list.erase(i)

func update_pellets_list(id: String, pellets: Sprite2D) -> void:
	if not current_pellets_list.has(id):
		current_pellets_list.set(id, pellets)

func update_players_list(id: String, players: Node2D) -> void:
	if not current_player_list.has(id):
		current_player_list.set(id, players)

func send_player_movement_input(x: float, y: float, _input_sequence: int = 0) -> void:
	var data: Dictionary = {"topic": "rooms.input","payload": {"x": x,"y": y}}
	WebsocketMultiplayerRouter.send_data_on_websocket(data)

func send_cashout_request() -> void:
	var data: Dictionary = {"topic": "rooms.leave","payload": {}}
	WebsocketMultiplayerRouter.send_important_data_on_websocket(data)

func send_join_room(room_id: String) -> void:
	#print("room_id: ", room_id)
	last_room_id = room_id
	var data: Dictionary = {
		"topic": "rooms.join",
		"payload": {
			"room_id": room_id,
			}
		}
	if GlobalManager.get_was_in_match() == false:
		data.topic = "rooms.join"
		data.payload.room_id = room_id
	else:
		data.topic = "rooms.rejoin"
		data.payload.room_id = room_id
	#print("join room request data: ", data)
	SignalManager.emit_open_loading_screen_signal(true)
	WebsocketMultiplayerRouter.send_important_data_on_websocket(data)
	#print("send join room with rejoin as: ", GlobalManager.get_was_in_match())

func send_ping() -> void:
	var data: Dictionary =   {
		"topic": "ping",
		"payload": {}
	}
	WebsocketMultiplayerRouter.send_data_on_websocket(data)
