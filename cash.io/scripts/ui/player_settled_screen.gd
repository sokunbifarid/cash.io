extends Control

@onready var match_state_label: Label = $PlayerSettledPanel/PlayerSettledVBoxContainer/MatchStateLabel
@onready var coin_status_label: Label = $PlayerSettledPanel/PlayerSettledVBoxContainer/CoinDataHBoxContainer/CoinStatusLabel
@onready var coin_saved_amount_label: Label = $PlayerSettledPanel/PlayerSettledVBoxContainer/CoinDataHBoxContainer/CoinSavedAmountLabel
@onready var coin_data_h_box_container: HBoxContainer = $PlayerSettledPanel/PlayerSettledVBoxContainer/CoinDataHBoxContainer
@onready var player_settled_panel: Panel = $PlayerSettledPanel

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

func _ready() -> void:
	SignalManager.match_over_signal.connect(_on_match_over_signal)

func open_player_settled_screen() -> void:
	self.show()
	player_settled_panel.show()
	player_settled_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(player_settled_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func _on_match_over_signal(data: Dictionary, condition: bool) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_ROOMS:
		open_player_settled_screen()
		GlobalManager.set_was_in_match(false, "")
		if data.has("coins"):
			match_state_label.show()
			coin_data_h_box_container.show()
			if data.coins > 0:
				match_state_label.text = "YOU SURVIVED LAST MATCH"
				coin_status_label.text = "Coin Saved:"
				coin_saved_amount_label.text = str(int(data.coins))
			else:
				match_state_label.text = "YOU LOST LAST MATCH"
				coin_status_label.text = "Coin Lost:"
				coin_saved_amount_label.text = str(int(data.coins))
		else:
			match_state_label.hide()
			coin_data_h_box_container.hide()


func _on_close_button_textured_1_pressed() -> void:
	self.hide()
