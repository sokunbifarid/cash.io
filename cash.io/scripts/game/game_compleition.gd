extends Control

@onready var game_state_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameStateLabel
@onready var time_used_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/TimeUsedLabel
@onready var coin_amount_value_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/CoinAmountHBoxContainer/CoinAmountValueLabel
@onready var coin_stats_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/CoinAmountHBoxContainer/CoinStatsLabel
@onready var total_coin_amount_h_box_container: HBoxContainer = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/TotalCoinAmountHBoxContainer
@onready var total_coin_amount_value_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/TotalCoinAmountHBoxContainer/TotalCoinAmountValueLabel

var player_starting_time: int = 0

func _ready() -> void:
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	SignalManager.wallet_updated_successfull_signal.connect(_on_wallet_updated_successfull_signal)
	self.hide()

func _on_prepare_game() -> void:
	self.hide()

func _on_wallet_updated_successfull_signal(value: int) -> void:
	total_coin_amount_value_label.text = str(value)

func calculate_time_used() -> int:
	return int(GameHttpNetworkManager.player_starting_time - GameHttpNetworkManager.player_running_time)

func _on_match_over_signal(data: Dictionary, condition: bool) -> void:
	if not GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME_COMPLETED:
		GlobalManager.current_game_state = GlobalManager.GAME_STATE.BUBBLE_GAME_COMPLETED
		var coin: int = 0
		if data.has("coin"):
			coin = data.coin
		if condition:
				game_state_label.text = "YOU SURVIVED"
				time_used_label.text = "Time Used: " + str(calculate_time_used()) + "s"
				coin_stats_label.text = "Coin Won: "
				coin_amount_value_label.text = str(coin)
				total_coin_amount_h_box_container.show()
		else:
			game_state_label.text = "YOU LOST"
			time_used_label.text = "Time Used: " + str(calculate_time_used()) + "s"
			coin_stats_label.text = "Coin Lost: "
			coin_amount_value_label.text = str(coin)
			total_coin_amount_h_box_container.hide()
		self.show()

func _on_home_button_textured_pressed() -> void:
	SignalManager.emit_reset_game_signal()
	self.hide()
