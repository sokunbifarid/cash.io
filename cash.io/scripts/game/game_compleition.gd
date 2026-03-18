extends Control

@onready var game_state_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameStateLabel
@onready var time_used_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/TimeUsedTextureRect/TimeUsedLabel
@onready var coin_stats_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/CoinDataTextureRect/CoinAmountHBoxContainer/CoinStatsLabel
@onready var coin_amount_value_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/CoinDataTextureRect/CoinAmountHBoxContainer/CoinAmountValueLabel
@onready var total_coin_data_texture_rect: TextureRect = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/TotalCoinDataTextureRect
@onready var total_coin_amount_value_label: Label = $GameCompletionPanel/GameCompletionDataVBoxContainer/GameCompletionDataSorterVBoxContainer/TotalCoinDataTextureRect/TotalCoinAmountHBoxContainer/TotalCoinAmountValueLabel
@onready var game_completion_panel: Panel = $GameCompletionPanel

var player_starting_time: int = 0
const GAME_COMPLETION_YOU_LOSE_SCREEN_PANEL = preload("uid://b0qdi75j3r6j5")
const GAME_COMPLETION_YOU_WIN_SCREEN_PANEL = preload("uid://4lbccp5v3h8g")

var the_visibility_tween: Tween
const TWEEN_DURATION: float = 0.3


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
		var style_box: StyleBoxTexture = StyleBoxTexture.new()
		if data.has("coin"):
			coin = data.coin
		if condition:
			style_box.texture = GAME_COMPLETION_YOU_WIN_SCREEN_PANEL
			game_completion_panel.add_theme_stylebox_override("panel", style_box)
			game_state_label.text = "YOU SURVIVED"
			time_used_label.text = "Time Used: " + str(calculate_time_used()) + "s"
			coin_stats_label.text = "Coin Won: "
			coin_amount_value_label.text = str(coin)
			total_coin_data_texture_rect.show()
		else:
			style_box.texture = GAME_COMPLETION_YOU_LOSE_SCREEN_PANEL
			game_completion_panel.add_theme_stylebox_override("panel", style_box)
			game_state_label.text = "YOU LOST"
			time_used_label.text = "Time Used: " + str(calculate_time_used()) + "s"
			coin_stats_label.text = "Coin Lost: "
			coin_amount_value_label.text = str(coin)
			total_coin_data_texture_rect.hide()
		open_game_completion()

func open_game_completion() -> void:
	self.show()
	game_completion_panel.show()
	game_completion_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(game_completion_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)


func _on_share_button_textured_pressed() -> void:
	print("share button pressed")
	pass # Replace with function body.


func _on_play_again_button_textured_pressed() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	SignalManager.emit_prepare_game_for_play_again_signal()
	await get_tree().create_timer(1).timeout
	GameHttpNetworkManager.send_join_room(GameHttpNetworkManager.last_room_id)

func _on_main_menu_button_textured_pressed() -> void:
	SignalManager.emit_reset_game_signal()
	self.hide()
