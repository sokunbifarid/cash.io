extends HBoxContainer

@onready var leaderboard_name_label: Label = $LeaderboardNameLabel
@onready var leaderboard_coin_label: Label = $LeaderboardCoinHBoxContainer/LeaderboardCoinLabel

func set_data(player_name: String = "", coin_value: String = "") -> void:
	leaderboard_name_label.text = player_name
	leaderboard_coin_label.text = coin_value

func is_player_data(condition: bool) -> void:
	if condition:
		leaderboard_name_label.label_settings.font_color = Color.ORANGE
		leaderboard_coin_label.label_settings.font_color = Color.ORANGE
	else:
		leaderboard_name_label.label_settings.font_color = Color.WHITE
		leaderboard_coin_label.label_settings.font_color = Color.WHITE
