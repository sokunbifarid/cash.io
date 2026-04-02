extends ws_schema

var current_player_list: Dictionary = {}
var current_pellets_list: Dictionary = {}
var current_player_id: String = ""
var player_starting_time: float = 90
var player_running_time: float = 0
var last_room_id: String = ""
var current_room_coin_cost: int = 0
var room_bound: Vector2 = Vector2.ZERO
const MAX_NUMBER_OF_RETRIES_TO_JOIN_ROOM: int = 3
var can_auto_join_room_on_launch: bool = true
var populate_pellets_list_basket_pellets: Array = []
var populate_player_list_basket_players: Array = []
const DEFAULT_PLAYER_TIME_IN_ROOM: float = 90.0 
var server_last_input_sequence: int = 0

#var ws_topics = Topic
var ms_topic = Topic

func _ready() -> void:
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.prepare_game_for_play_again_signal.connect(_on_prepare_game_for_play_again_signal)
	SignalManager.match_over_signal.connect(_on_match_over_signal)

func _on_match_over_signal() -> void:
	player_running_time = 0
	room_bound = Vector2.ZERO

func _on_prepare_game_for_play_again_signal() -> void:
	current_pellets_list = {}
	current_player_list = {}
	player_running_time = 0

func _on_reset_game_signal() -> void:
	current_player_id = ""
	current_pellets_list = {}
	current_player_list = {}
	player_running_time = 0
	last_room_id = ""

func network_process(payload: Dictionary) -> void:
	#print("websocket server reply payload: ", payload)
	map_networked_payload(payload)

func get_current_player_id() -> String:
	return current_player_id

func set_current_player_id(value: String) -> void:
	current_player_id = value

func set_current_room_coin_cost(value: int) -> void:
	current_room_coin_cost = value

func get_current_room_coin_cost() -> int:
	return current_room_coin_cost

func map_networked_payload(payload: Dictionary) -> void:
	if payload.has("topic"):
		var payload_topic: int = payload.topic#payload.topic#: String = payload.topic
		match payload_topic:
			ms_topic.GET_ROOMS:#ws_topics.GET_ROOMS:
				append_get_room(payload)
			ms_topic.ROOMS_JOIN:#ws_topics.ROOMS_JOIN:
				print("room join called response obtained: ", payload)
				append_rooms_join_data(payload)
			ms_topic.ROOMS_REJOIN:#ws_topics.ROOMS_REJOIN:
				append_rooms_rejoin_data(payload)
			ms_topic.ROOMS_JOINED:#ws_topics.ROOMS_JOINED:
				append_room_joined_data(payload)
			ms_topic.ROOMS_PLAYER_SETTLED:#ws_topics.ROOMS_PLAYER_SETTLED:
				print("rooms player settled response obtained: ", payload)
				append_player_settled_data(payload)
			ms_topic.ROOMS_PLAYER_ELIMINATED:#ws_topics.ROOMS_PLAYER_ELIMINATED:
				print("rooms player eliminated response obtained: ", payload)
				append_player_eliminated_data(payload)
			ms_topic.WALLET_UPDATED:#ws_topics.WALLET_UPDATED:
				append_wallet_updated_data(payload)
			ms_topic.ROOMS_CASHOUT_REJECTED:#ws_topics.ROOMS_CASHOUT_REJECTED:
				print("room cashout rejected response obtained: ", payload)
			ms_topic.ROOMS_POWERUP_UPDATED:#ws_topics.ROOMS_POWERUP_UPDATED:
				print("room powerup updated response obtained: ", payload)
				append_powerup_used_data(payload)
			ms_topic.ROOMS_SNAPSHOT:#ws_topics.ROOMS_SNAPSHOT:
				append_snapshot_data(payload)
			ms_topic.ROOMS_TIME_LEFT:#ws_topics.ROOMS_TIME_LEFT:
				append_rooms_time_left_data(payload)
			ms_topic.ROOMS_INPUT:#ws_topics.ROOMS_INPUT:
				append_room_input_data(payload)
				print("rooms input response obtained: ", payload)
			ms_topic.ROOMS_LEAVE:#ws_topics.ROOMS_LEAVE:
				print("room leave response obtained: ", payload)
			ms_topic.ROOMS_DISCONNECT:#ws_topics.ROOMS_DISCONNECT:
				print("room disconnected response obtained: ", payload)
			ms_topic.ROOMS_POWERUP_USE:#ws_topics.ROOMS_POWERUP_USE:
				print("powerup used response obtained: ", payload)
			ms_topic.DEPOSITS_CREATE:#ws_topics.DEPOSITS_CREATE:
				append_deposits_create_data(payload)
			ms_topic.WITHDRAWALS_CREATE:#ws_topics.WITHDRAWALS_CREATE:
				append_withdrawals_create_data(payload)
			ms_topic.WITHDRAWALS_ACCOUNT_STATUS:#ws_topics.WITHDRAWALS_ACCOUNT_STATUS:
				append_withdrawal_account_status_data(payload)
			ms_topic.GET_ME:#ws_topics.GET_ME:
				append_get_me(payload)
			ms_topic.SET_AVATAR:#ws_topics.SET_AVATAR:
				print("set avatar")
			ms_topic.GET_SHOP_CATALOG:#ws_topics.GET_SHOP_CATALOG:
				append_shop_catalog(payload)
			ms_topic.BUY_CATALOG_ITEM:#ws_topics.BUY_CATALOG_ITEM:
				print("catalog item bought response obtained: ", payload)
				append_buy_catalog_item_response(payload)
			#"session.connected":
				#append_session_connected_data(payload)
			#"gateway.error":
				#append_gateway_error_data(payload)
			#"session.heartbeat":
				#print(payload)
			#"rooms.joined":
				#append_room_joined_data(payload)
			#"rooms.snapshot":
				#append_snapshot_data(payload)
			#"rooms.player_settled":
				#append_player_settled_data(payload)
			#"rooms.player_eliminated":
				#append_player_eliminated_data(payload)
			#"rooms.cashout_rejected":
				#append_cashout_rejected_data(payload)
			#"wallet.updated":
				#append_wallet_updated_data(payload)
			#"wallet.settlement_failed":
				#append_wallet_settlement_failed_data(payload)
			#"rooms.powerup.updated":
				#append_powerup_used_data(payload)

func append_rooms_join_data(payload: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(false)
	if payload.has("error_body"):
		if payload.error_body.has("message"):
			if payload.error_body.message == "use_rejoin":
				send_join_room(last_room_id)
				return
			SignalManager.emit_notice_signal(payload.error_body.message)

func append_room_input_data(payload: Dictionary) -> void:
	#rooms input response obtained: { "error_body": { "message": "invalid_room_id" }, "room_id": "", "topic": 14.0 }
	if payload.has("error_body"):
		if payload.error_body.has("message"):
			print("cannot send user input because, " + payload.error_body.message)

func append_buy_catalog_item_response(payload: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(false)
	if payload.has("error_body"):
		if payload.error_body.has("message"):
			SignalManager.emit_notice_signal(payload.error_body.message)
			return
	if payload.has("buy_catalog_item_body"):
		SignalManager.emit_shop_purchase_successful_signal()

func append_rooms_time_left_data(payload: Dictionary) -> void:
	print("room timer left data: ", payload)
	if payload.has("session_state"):
		if payload.session_state.has("remaining_sec"):
			player_running_time = payload.session_state.remaining_sec
		if payload.session_state.has("last_input_seq"):
			server_last_input_sequence = payload.session_state.last_input_seq

func append_rooms_rejoin_data(payload: Dictionary) -> void:
	if payload.has("error_body"):
		if payload.error_body.has("message"):
			if payload.error_body.message == "rejoin_not_available":
				GlobalManager.set_was_in_match(false, "")
				#send_join_room(last_room_id)
				SignalManager.emit_match_over_signal({}, false)
				SignalManager.emit_open_loading_screen_signal(false)

func append_withdrawals_create_data(payload: Dictionary) -> void:
	print("append withdrawals create data: ", payload)
	SignalManager.emit_open_loading_screen_signal(false)
	if payload.has("error_body"):
		if payload.error_body.has("message"):
			SignalManager.emit_notice_signal(payload.error_body.message)
			return

func append_withdrawal_account_status_data(payload: Dictionary) -> void:
	SignalManager.emit_open_loading_screen_signal(false)
	if payload.has("withdrawal_account_status_body"):
		if payload.withdrawal_account_status_body.has("value"):
			if payload.withdrawal_account_status_body.value == false:
				SignalManager.emit_withdrawal_form_prompt_signal()
			elif payload.withdrawal_account_status_body.value == true:
				SignalManager.emit_withdrawal_data_prompt_signal()
			return
	SignalManager.emit_notice_signal("Error attempting withdrawal")

func append_deposits_create_data(payload: Dictionary) -> void:
	if payload.has("deposit_created_body"):
		if payload.deposit_created_body.has("checkout_url"):
			if OS.get_name() == "iOS" or OS.get_name() == "macOS":
				OS.execute("open", [payload.deposit_created_body.checkout_url])
			else:
				OS.shell_open(payload.deposit_created_body.checkout_url)
			return
	SignalManager.emit_open_loading_screen_signal(false)
	SignalManager.emit_notice_signal("Issue proceeding with deposit")

func append_get_room(payload: Dictionary) -> void:
	if payload.has("rooms"):
		if payload.rooms.has("items"):
			var response: Dictionary = {"rooms": []}
			response.rooms = payload.rooms.items
			SignalManager.emit_all_rooms_loaded_signal(response)
			#SignalManager.emit_open_loading_screen_signal(false)
			HttpNetworkManager.request_http_shop()
			return
	SignalManager.emit_error_getting_user_data_signal()
	SignalManager.emit_notice_signal("Issue Getting Room List")
	SignalManager.emit_open_loading_screen_signal(false)

func append_shop_catalog(payload: Dictionary) -> void:
	if payload.has("shop_catalog"):
		if payload.shop_catalog.has("items"):
			var response: Dictionary = {"items": []}
			response.items = payload.shop_catalog.items
			SignalManager.emit_shop_data_loaded_signal(response)
			SignalManager.emit_open_loading_screen_signal(false)
			SignalManager.emit_startup_request_data_loaded_successfully()
			return
	SignalManager.emit_error_getting_user_data_signal()
	SignalManager.emit_notice_signal("Issue Getting Shop Data")
	SignalManager.emit_open_loading_screen_signal(false)

func append_get_me(payload: Dictionary) -> void:
	if payload.has("user_payload"):
		var result_data: Dictionary = {
			"username": "",
			"wallet_balance": 0,
			"active_avatar": "",
			"owned_avatars": [],
			"owned_powerups": []}
		if payload.user_payload.has("username"):
			result_data.username = payload.user_payload.username
		if payload.user_payload.has("wallet_balance"):
			result_data.wallet_balance = payload.user_payload.wallet_balance
		if payload.user_payload.has("active_avatar"):
			result_data.active_avatar = payload.user_payload.active_avatar
		if payload.user_payload.has("owned_avatars"):
			result_data.owned_avatars = payload.user_payload.owned_avatars
		if payload.user_payload.has("inventory"):
			result_data.owned_powerups = payload.user_payload.inventory
		set_current_player_id(payload.user_payload.get("user_id"))
		SignalManager.emit_player_data_loaded_successfully_signal(result_data)
		HttpNetworkManager.request_http_room_list()
		return
	SignalManager.emit_notice_signal("Issue loading player data")
	SignalManager.emit_error_getting_user_data_signal()
	#SignalManager.emit_open_loading_screen_signal(false)

func append_session_connected_data(_payload: Dictionary) -> void:
	#SignalManager.emit_open_loading_screen_signal(false)
	print("session connected")
	send_heartbeat()
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.AUTH:
		pass
		if can_auto_join_room_on_launch == false:
			SignalManager.emit_startup_request_data_loaded_successfully()
		if can_auto_join_room_on_launch:#else:
			print("can auto join room is true")
			if GlobalManager.get_was_in_match():
				print("detected player was in a match previously")
				send_join_room(GlobalManager.get_last_match_room_id())
				print("trying to join last match")
			else:
				print("detected player was not in match previously")
				SignalManager.emit_startup_request_data_loaded_successfully()
	else:
		SignalManager.emit_websocket_reconnected_signal()

#not used
func append_gateway_error_data(payload: Dictionary) -> void:
	print("gateway payload: ", payload)
	if payload.has("payload"):
		if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_ROOMS:
			if payload.payload.has("message"):
				if payload.payload.message == "rejoin_not_available":
					SignalManager.emit_match_over_signal({}, true)
				if payload.payload.message == "room_not_joined":
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

	#if payload.has("payload"):
		#if payload.payload.has("pellets"):
			#if payload.payload.pellets.size() > 0:
				#populate_pellets_list(payload.payload.pellets)
		#if payload.payload.has("players"):
			#if payload.payload.players.size() > 0:
				#populate_player_list(payload.payload)
		#if payload.payload.has("powerups"):
			#if payload.payload.powerups.size() > 0:
				#SignalManager.emit_load_in_game_powersups_signal(payload.payload.powerups)
		#if payload.payload.has("remaining_sec"):
			#player_starting_time = payload.payload.remaining_sec
			#if payload.payload.remaining_sec == DEFAULT_PLAYER_TIME_IN_ROOM:
				#if current_player_list.has(current_player_id):
					#PowerupsManager.force_use_shield()
		#if payload.payload.has("remaining_sec") or payload.payload.has("pellets") or payload.payload.has("players"):
			#SignalManager.emit_open_loading_screen_signal(false)
			#GlobalManager.set_was_in_match(true, last_room_id)
			#SignalManager.emit_prepare_game_signal()
		#GlobalManager.current_game_state = GlobalManager.GAME_STATE.BUBBLE_GAME
	if payload.has("error_body"):
		if payload.error_body.has("message"):
			if payload.error_body.message == "use_rejoin":
				SignalManager.emit_notice_signal("Joining Last Match")
				send_join_room(GlobalManager.get_last_match_room_id())
				return
	if payload.has("initial_payload"):
		if payload.initial_payload.has("pellets"):
			if payload.initial_payload.pellets.size() > 0:
				populate_pellets_list(payload.initial_payload.pellets)
		if payload.initial_payload.has("players"):
			if payload.initial_payload.players.size() > 0:
				populate_player_list(payload.initial_payload)
		if payload.initial_payload.has("powerups"):
			if payload.initial_payload.powerups.size() > 0:
				SignalManager.emit_load_in_game_powersups_signal(payload.initial_payload.powerups)
		if payload.initial_payload.has("remaining_sec"):
			#player_starting_time = payload.initial_payload.remaining_sec
			if payload.initial_payload.remaining_sec == DEFAULT_PLAYER_TIME_IN_ROOM:
				if current_player_list.has(current_player_id):
					PowerupsManager.force_use_shield()
		if payload.initial_payload.has("bounds"):
			room_bound = Vector2(payload.initial_payload.bounds.width, payload.initial_payload.bounds.height)

		if payload.initial_payload.has("remaining_sec") or payload.initial_payload.has("pellets") or payload.initial_payload.has("players"):
			SignalManager.emit_open_loading_screen_signal(false)
			GlobalManager.set_was_in_match(true, last_room_id)
			SignalManager.emit_prepare_game_signal()
			print("this shit is buggling")
		GlobalManager.current_game_state = GlobalManager.GAME_STATE.BUBBLE_GAME

#"powerups": [{ "id": "8d6bb1c8-3f7f-4c8c-9ef8-6c5a4f0c1b72", "name": "Turbo Booster", "quantity": 20.0 }, { "id": "2f8a9f3d-0f4c-4b9f-8d1d-2f6a7c1e5b13", "name": "Guardian Shield", "quantity": 11.0 }, { "id": "7b14d3c2-6e5a-4c11-9c7e-3d8f2a6b4e90", "name": "Flash Speed", "quantity": 5.0 }], "remaining_sec": 90.0 } }

func append_snapshot_data(payload: Dictionary) -> void:
	#SignalManager.emit_open_loading_screen_signal(false)
	#print("update snapshot,: ", payload)
	#if payload.has("payload"):
		#if payload.payload.has("updated_players"):
			#if payload.payload.updated_players.size() > 0:
				#update_players(payload.payload.updated_players)
		#if payload.payload.has("spawned_players"):
			#if payload.payload.spawned_players.size() > 0:
				#populate_player_list(payload.payload)
		#if payload.payload.has("removed_players"):
			#if payload.payload.removed_players.size() > 0:
				#remove_eaten_players(payload.payload.removed_players)
		#if payload.payload.has("spawned_pellets"):
			#if payload.payload.spawned_pellets.size() > 0:
				#spawned_pellets(payload.payload.spawned_pellets)
		#if payload.payload.has("removed_pellets"):
			#if payload.payload.removed_pellets.size() > 0:
				#remove_eaten_pellets(payload.payload.removed_pellets)
		#if payload.payload.has("remaining_sec"):
			#player_running_time = payload.payload.remaining_sec
			##if payload.payloa
		#if payload.payload.has("bounds"):
			#room_bound = Vector2(payload.payload.bounds.width, payload.payload.bounds.height)


#{"room_id":"","snapshot_payload":{"bounds":{"height":5000.0,"width":5000.0},"removed_pellets":[],"removed_players":[],"spawned_pellets":[],"spawned_players":[],"updated_players":[{"coins":1,"id":"google-oauth2|111573010780317288794","mass":100.0,"x":1828.98714174498,"y":371.024026117302}]},"topic":12}
#envelope data: {"number_body":{"value":89},"room_id":"","topic":13}
	#continue here
	SignalManager.emit_open_loading_screen_signal(false)
	#print("update snapshot,: ", payload)
	if payload.has("snapshot_payload"):
		if payload.snapshot_payload.has("updated_players"):
			if payload.snapshot_payload.updated_players != null:
				if payload.snapshot_payload.updated_players.size() > 0:
					update_players(payload.snapshot_payload.updated_players)
		if payload.snapshot_payload.has("spawned_players"):
			if payload.snapshot_payload.spawned_players != null:
				if payload.snapshot_payload.spawned_players.size() > 0:
					populate_player_list(payload.snapshot_payload)
		if payload.snapshot_payload.has("removed_players"):
			if payload.snapshot_payload.removed_players != null:
				if payload.snapshot_payload.removed_players.size() > 0:
					remove_eaten_players(payload.snapshot_payload.removed_players)
		if payload.snapshot_payload.has("spawned_pellets"):
			if payload.snapshot_payload.spawned_pellets != null:
				if payload.snapshot_payload.spawned_pellets.size() > 0:
					spawned_pellets(payload.snapshot_payload.spawned_pellets)
		if payload.snapshot_payload.has("removed_pellets"):
			if payload.snapshot_payload.removed_pellets != null:
				if payload.snapshot_payload.removed_pellets.size() > 0:
					remove_eaten_pellets(payload.snapshot_payload.removed_pellets)
		if payload.snapshot_payload.has("remaining_sec"):
			if payload.snapshot_payload.remaining_sec != null:
				#print("remaining time snap shot sent")
				player_running_time = payload.snapshot_payload.remaining_sec
		if payload.snapshot_payload.has("bounds"):
			if payload.snapshot_payload.bounds != null:
				room_bound = Vector2(payload.snapshot_payload.bounds.width, payload.snapshot_payload.bounds.height)



func append_player_settled_data(payload: Dictionary) -> void:
	#print("trying to append player_settled_data: ", payload)
	#var data: Dictionary = {"coins": 0}
	#GlobalManager.set_was_in_match(false, "")
	#if payload.has("payload"):
		#if payload.payload.has("coins"):
			#data.coins = payload.payload.coins
	#SignalManager.emit_match_over_signal(data, true)
	var data: Dictionary = {"coin": 0}
	print("player settled successfully")
	SignalManager.emit_open_loading_screen_signal(false)
	GlobalManager.set_was_in_match(false, "")
	if payload.has("number_body"):
		if payload.number_body.has("value"):
			data.coin = int(payload.number_body.value)
	SignalManager.emit_match_over_signal(data, true)

func append_player_eliminated_data(_payload: Dictionary) -> void:
	var data: Dictionary = {"coin": get_current_room_coin_cost()}
	GlobalManager.set_was_in_match(false, "")
	SignalManager.emit_match_over_signal(data, false)

func append_cashout_rejected_data(payload: Dictionary) -> void:
	#print("cashout rejected: ", payload)
	if payload.has("payload"):
		if payload.payload.has("wait_ms"):
			SignalManager.emit_cashout_rejected_signal(payload.payload.wait_ms)

func append_wallet_updated_data(payload: Dictionary) -> void:
	print("wallet updated: ", payload)
	#if payload.has("payload"):
		#if payload.payload.has("amount"):
			##print("appending wallet updated data")
			#SignalManager.emit_wallet_updated_successfull_signal(int(payload.payload.amount))
			#SignalManager.emit_open_loading_screen_signal(false)
	if payload.has("number_body"):
		if payload.number_body.has("value"):
			SignalManager.emit_wallet_updated_successfull_signal(int(payload.number_body.value))


func append_wallet_settlement_failed_data(payload: Dictionary) -> void:
	#print("wallet settlement failed: ", payload)
	if payload.has("detail"):
		SignalManager.emit_wallet_settlement_failed_signal(payload.detail)

#"powerups": [{ "id": "8d6bb1c8-3f7f-4c8c-9ef8-6c5a4f0c1b72", "name": "Turbo Booster", "quantity": 20.0 }, { "id": "2f8a9f3d-0f4c-4b9f-8d1d-2f6a7c1e5b13", "name": "Guardian Shield", "quantity": 11.0 }, { "id": "7b14d3c2-6e5a-4c11-9c7e-3d8f2a6b4e90", "name": "Flash Speed", "quantity": 5.0 }], "remaining_sec": 90.0 } }

func append_powerup_used_data(payload: Dictionary) -> void:
	#print("powerup payload data received: ", payload.payload)
	#if payload.has("payload"):
		#SignalManager.emit_player_used_powerup_signal(payload.payload)
		#print("powerups initiated")
	if payload.has("powerup_body"):
		SignalManager.emit_player_used_powerup_signal(payload.powerup_body)
		print("powerups initiated")

func spawned_pellets(payload: Array) -> void:
	#print("spawned pellets: ", payload)
	populate_pellets_list(payload)

func populate_player_list(payload: Dictionary) -> void:
	populate_player_list_basket_players = []
	#print("populate player payload: ", payload)
	var temp_player_list: Array = []
	if payload.has("bounds"):
		room_bound = Vector2(payload.bounds.width, payload.bounds.height)
		#print("bounds set here")
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
	#print("populating pellets list: ", payload)
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
					if i.has("x") and i.has("y"):
						new_pos = Vector2(i.x, i.y)
					if i.has("coins"):
						coin = i.coins
					if i.has("mass"):
						mass = i.mass
					#print("players position getting updated, mass: %s, coin: %s, new_position: %s" % [mass, coin, new_pos])
					#print("this player with id: %s, has an old raw position of: %s and a new raw position of: %s" % [i.id, current_player_list[i.id].next_pos, new_pos])
					current_player_list[i.id].set_data(new_pos, mass, coin)
					#current_player_list[i.id + "1"].set_data(new_pos, mass, coin) # use to test player shadow for movement

func remove_eaten_players(payload: Array) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		#print("remove eaten players payload: ", payload)
		for i: String in payload:
			if current_player_list.has(i):
				current_player_list[i].character_disabled()
				current_player_list.erase(i)

func remove_eaten_pellets(payload: Array) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		#print("remove eaten pellets payload: ", payload)
		for i: String in payload:
			if current_pellets_list.has(i):
				if current_player_list.has(current_player_id):
					print("distance of pellets to deleted player: ", current_pellets_list[i].position.distance_to(current_player_list[current_player_id].position))
					if current_pellets_list[i].position.distance_to(current_player_list[current_player_id].position) < current_player_list[current_player_id].get_mass():
						SfxAudioManager.play_eat_pellets_sfx()
				current_pellets_list[i].queue_free()
				current_pellets_list.erase(i)

func update_pellets_list(id: String, pellets: Sprite2D) -> void:
	if not current_pellets_list.has(id):
		current_pellets_list.set(id, pellets)

func update_players_list(id: String, players: Node2D) -> void:
	if not current_player_list.has(id):
		current_player_list.set(id, players)

func send_player_movement_input(x: float, y: float, input_seq: int = 0) -> void:
	#var data: Dictionary = {"topic": "rooms.input","payload": {"x": x,"y": y}}
	#print("attempting to send player movement input with room id: " + str(last_room_id))
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.ROOMS_INPUT
	var player_input_data: InputBody = InputBody.new()
	player_input_data.dx = x
	player_input_data.dy = y
	player_input_data.input_seq = input_seq
	envelope.input_body = player_input_data
	envelope.room_id = last_room_id
	WebsocketMultiplayerRouter.send_data_on_websocket(envelope)
	#WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	#WebsocketMultiplayerRouter.send_data_on_websocket(data)

func send_cashout_request() -> void:
	#var data: Dictionary = {"topic": "rooms.leave","payload": {}}
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.ROOMS_LEAVE
	envelope.room_id = last_room_id
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	#print("cashout being called")
	#WebsocketMultiplayerRouter.send_important_data_on_websocket(data)

func send_use_powerup(id: String) -> void:
	#var data: Dictionary = {"topic": "rooms.powerup.use","payload": {"id": id}}
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.ROOMS_POWERUP_USE
	var powerup_to_use: PowerupBody = PowerupBody.new()
	powerup_to_use.id = id
	envelope.powerup_body = powerup_to_use
	envelope.room_id = last_room_id
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	#print("powerups being called")
	#WebsocketMultiplayerRouter.send_data_on_websocket(data)

func send_join_room(room_id: String) -> void:
	#print("room_id: ", room_id)
	last_room_id = room_id
	var envelope: Envelope = Envelope.new()
	#var data: Dictionary = {
		#"topic": "rooms.join",
		#"payload": {
			#"room_id": room_id,
			#}
		#}
	if GlobalManager.get_was_in_match() == false:
		#data.topic = "rooms.join"
		#data.payload.room_id = room_id
		envelope.topic = Topic.ROOMS_JOIN
		envelope.room_id = room_id
	else:
		#data.topic = "rooms.rejoin"
		#data.payload.room_id = room_id
		envelope.topic = Topic.ROOMS_REJOIN
		envelope.room_id = room_id
		
	#print("join room request data: ", data)
	SignalManager.emit_open_loading_screen_signal(true)
	#WebsocketMultiplayerRouter.send_important_data_on_websocket(data)
	WebsocketMultiplayerRouter.send_important_data_on_websocket(envelope)
	#print("send join room with rejoin as: ", GlobalManager.get_was_in_match())

func send_heartbeat() -> void:
	#var data: Dictionary = {"topic": "session.heartbeat","payload": {}}
	#WebsocketMultiplayerRouter.send_data_on_websocket(data)
	var envelope: Envelope = Envelope.new()
	envelope.topic = Topic.PING
	#print("envelope on heartbeat ", envelope)
	WebsocketMultiplayerRouter.send_data_on_websocket(envelope)
	#print("heartbeat sent to the server")
