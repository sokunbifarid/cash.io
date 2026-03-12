extends Panel


@onready var leaderboard_item_sorter_v_box_container: VBoxContainer = $LeaderboardVBoxContainer/LeaderboardItemSorterVBoxContainer
var players_list: Dictionary = {}
var recorded_players_id: Array = []
var player_with_higest_coin_name: String = ""
var players_with_highest_coin_coin_count: int = 0
const WEBSOCKET_SERVER_FRAME_TICK: float = 1.0/60.0
var websocket_tick_count: float = 0

func _ready() -> void:
	hide_all_leaderboard_item()
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	set_process(false)

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
	if not websocket_tick_count > WEBSOCKET_SERVER_FRAME_TICK:
		websocket_tick_count += delta
		return
	else:
		websocket_tick_count = 0
	var focused_character: Dictionary = {}
	players_list = GameHttpNetworkManager.current_player_list
	if players_list.size() > 0:
		var leaderboard_position: int = 1
		for j in leaderboard_item_sorter_v_box_container.get_child_count():
			if j != leaderboard_item_sorter_v_box_container.get_child_count() - 1:
				leaderboard_item_sorter_v_box_container.get_child(j).hide()
				player_with_higest_coin_name = ""
				for i in players_list:
					if not recorded_players_id.has(i):
						if players_list[i].current_coin >= players_with_highest_coin_coin_count:
							players_with_highest_coin_coin_count = players_list[i].current_coin
							player_with_higest_coin_name = players_list[i].current_name.left(5)
							recorded_players_id.append(i)
				if player_with_higest_coin_name != "":
					leaderboard_item_sorter_v_box_container.get_child(j).show()
					leaderboard_item_sorter_v_box_container.get_child(j).text = str(leaderboard_position) + ". " + player_with_higest_coin_name + ":  " + str(players_with_highest_coin_coin_count) + " coins"
					leaderboard_item_sorter_v_box_container.get_child(j).modulate = Color.WHITE
					leaderboard_position += 1
			else:
				if players_list.has(str(GameHttpNetworkManager.get_current_player_id())):
					leaderboard_item_sorter_v_box_container.get_child(j).show()
					leaderboard_item_sorter_v_box_container.get_child(j).text = str(leaderboard_position) + ". " + players_list[GameHttpNetworkManager.get_current_player_id()].current_name.left(5) + ":  " + str(players_list[GameHttpNetworkManager.get_current_player_id()].current_coin) + " coins"
					leaderboard_item_sorter_v_box_container.get_child(j).modulate = Color.ORANGE
					leaderboard_position += 1

func populate_list_of_leaderboard_items(data: Dictionary) -> void:
	hide_all_leaderboard_item()
	var data_keys: Array = []
	var leaderboard_items_sorter_child_count: int = leaderboard_item_sorter_v_box_container.get_child_count()
	for item in data.keys():
		data_keys.append(item)
	for i: int in range(0, data_keys.size()):
		if i < leaderboard_items_sorter_child_count:
			leaderboard_item_sorter_v_box_container.get_child(i).text = data[data_keys[i]]
