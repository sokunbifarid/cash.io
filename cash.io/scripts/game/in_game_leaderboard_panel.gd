extends Panel


@onready var leaderboard_item_sorter_v_box_container: VBoxContainer = $LeaderboardVBoxContainer/LeaderboardItemSorterVBoxContainer
var players_list: Dictionary = {}
var recorded_players_id: Array = []

func _ready() -> void:
	hide_all_leaderboard_item()
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	SignalManager.prepare_game_for_play_again_signal.connect(_on_prepare_game_for_play_again_signal)
	set_process(false)

func _on_prepare_game_for_play_again_signal() -> void:
	set_process(false)
	players_list = {}
	recorded_players_id = []

func _on_prepare_game() -> void:
	set_process(true)
	players_list = {}
	recorded_players_id = []

func _on_match_over_signal(_data: Dictionary, _status: bool) -> void:
	set_process(false)
	players_list = {}
	recorded_players_id = []

func hide_all_leaderboard_item() -> void:
	for child in leaderboard_item_sorter_v_box_container.get_children():
		child.hide()

func _process(delta: float) -> void:
	sort_leaderboard_list()
	#var focused_character: Dictionary = {}
	#var leaderboard_position: int = 1
	#players_list = GameHttpNetworkManager.current_player_list
	#if players_list.size() > 0:
		#for i in leaderboard_item_sorter_v_box_container.get_child_count():
			#leaderboard_item_sorter_v_box_container.get_child(i).hide()
			#player_with_higest_coin_id = ""
			#for j in players_list:
				#if not recorded_players_id.has(j):
					#if players_list[j].current_coin >= players_with_highest_coin_coin_count:
						#players_with_highest_coin_coin_count = players_list[j].current_coin
						#player_with_higest_coin_id = j
			#if player_with_higest_coin_id != "":
				#recorded_players_id.append(player_with_higest_coin_id)
		#if not recorded_players_id.has(GameHttpNetworkManager.get_current_player_id()):
			#recorded_players_id[recorded_players_id.size() - 1] = GameHttpNetworkManager.get_current_player_id()
		#for l in players_list.size():#leaderboard_item_sorter_v_box_container.get_child_count():
			#if l < leaderboard_item_sorter_v_box_container.get_child_count() and players_list.has(recorded_players_id[l]):
				#leaderboard_item_sorter_v_box_container.get_child(l).show()
				#leaderboard_item_sorter_v_box_container.get_child(l).set_data(str(leaderboard_position) + ". " + players_list[recorded_players_id[l]].current_name.left(7), str(players_list[recorded_players_id[l]].current_coin))
				#if recorded_players_id[l] == GameHttpNetworkManager.get_current_player_id():
					#leaderboard_item_sorter_v_box_container.get_child(l).is_player_data(true)
				#else:
					#leaderboard_item_sorter_v_box_container.get_child(l).is_player_data(false)
				#leaderboard_position += 1
	
		#var leaderboard_position: int = 1
		#for j in leaderboard_item_sorter_v_box_container.get_child_count():
			#if j != leaderboard_item_sorter_v_box_container.get_child_count() - 1:
				#leaderboard_item_sorter_v_box_container.get_child(j).hide()
				#player_with_higest_coin_name = ""
				#for i in players_list:
					#if not recorded_players_id.has(i):
						#if players_list[i].current_coin >= players_with_highest_coin_coin_count:
							#players_with_highest_coin_coin_count = players_list[i].current_coin
							#player_with_higest_coin_name = players_list[i].current_name.left(5)
							#recorded_players_id.append(i)
				#if player_with_higest_coin_name != "":
					#leaderboard_item_sorter_v_box_container.get_child(j).show()
					#leaderboard_item_sorter_v_box_container.get_child(j).text = str(leaderboard_position) + ". " + player_with_higest_coin_name + ":  " + str(players_with_highest_coin_coin_count) + " coins"
					#leaderboard_item_sorter_v_box_container.get_child(j).modulate = Color.WHITE
					#leaderboard_position += 1
			#else:
				#if players_list.has(str(GameHttpNetworkManager.get_current_player_id())):
					#leaderboard_item_sorter_v_box_container.get_child(j).show()
					#leaderboard_item_sorter_v_box_container.get_child(j).text = str(leaderboard_position) + ". " + players_list[GameHttpNetworkManager.get_current_player_id()].current_name.left(5) + ":  " + str(players_list[GameHttpNetworkManager.get_current_player_id()].current_coin) + " coins"
					#leaderboard_item_sorter_v_box_container.get_child(j).modulate = Color.ORANGE
					#leaderboard_position += 1

func sort_leaderboard_list() -> void:
	var leaderboard_data: Array = get_leaderboard(GameHttpNetworkManager.current_player_list, GameHttpNetworkManager.get_current_player_id())
	var count: int = 1
	for i in leaderboard_item_sorter_v_box_container.get_children():
		i.hide()
	if leaderboard_data.size() > 0:
		for i in range (leaderboard_item_sorter_v_box_container.get_child_count()):
			if i < leaderboard_data.size():
				leaderboard_item_sorter_v_box_container.get_child(i).show()
				leaderboard_item_sorter_v_box_container.get_child(i).set_data(str(count) + ". " + leaderboard_data[i]["name"], str(leaderboard_data[i]["coins"]))
				if leaderboard_data[i]["id"] == GameHttpNetworkManager.get_current_player_id():
					leaderboard_item_sorter_v_box_container.get_child(i).is_player_data(true)
				else:
					leaderboard_item_sorter_v_box_container.get_child(i).is_player_data(false)
				count += 1

func get_leaderboard(characters: Dictionary, current_player_id):
	var list = []
# Convert dictionary to array
	for id in characters.keys():
		var character = characters[id]
		list.append({
			"id": id,
			"name": character.current_name,
			"coins": character.current_coin
			})
# Sort ascending (highest → lowest)
	list.sort_custom(func(a, b):
		return a["coins"] > b["coins"]
	)
# Take top 5
	var leaderboard: Array = list.slice(0, 5)
# Check if current player is already inside
	var found = false
	for entry in leaderboard:
		if entry["id"] == current_player_id:
			found = true
			break
# If not in top 5 → force them into position 5
	if not found:
		var current_character = characters[current_player_id]
		leaderboard[-1] = {
				"id": current_player_id,
				"name": current_character.current_name,
				"coins": current_character.current_coin
			}
	return leaderboard

func populate_list_of_leaderboard_items(data: Dictionary) -> void:
	hide_all_leaderboard_item()
	var data_keys: Array = []
	var leaderboard_items_sorter_child_count: int = leaderboard_item_sorter_v_box_container.get_child_count()
	for item in data.keys():
		data_keys.append(item)
	for i: int in range(0, data_keys.size()):
		if i < leaderboard_items_sorter_child_count:
			leaderboard_item_sorter_v_box_container.get_child(i).text = data[data_keys[i]]
