extends Control

signal buy_coin_button

@onready var coin_value_label: Label = $BuyCoinButtonTextured/ButtonSorterHBoxContainer/ButtonIconTextureRect/CoinValueLabel
@onready var coin_increment_animation_label: Label = $CoinIncrementAnimationLabel

var the_tween: Tween

var last_coin_amount: int = 0
const TWEEN_DURATION: float = 1.0

func _ready() -> void:
	connect_signal()
	coin_increment_animation_label.text = ""

func connect_signal() -> void:
	SignalManager.player_data_loaded_successfully_signal.connect(_on_player_data_loaded_successfully_signal)
	SignalManager.wallet_updated_successfull_signal.connect(_on_wallet_updated_successfull_signal)

func _on_wallet_updated_successfull_signal(value: int) -> void:
	set_coin_value(value)
	

func _on_player_data_loaded_successfully_signal(payload: Dictionary) -> void:
	if payload.has("wallet_balance"):
		set_coin_value(payload.wallet_balance)

func set_coin_value(value: int) -> void:
	var coin_amount: int = value
	coin_value_label.text = str(coin_amount)
	if coin_amount <= 10000:
		coin_value_label.label_settings.font_size = 12
	elif coin_amount > 10000 and coin_amount < 100000:
		coin_value_label.label_settings.font_size = 10
	else:
		coin_value_label.label_settings.font_size = 8
	check_coin_last_amount(value)

func check_coin_last_amount(value: int) -> void:
	if last_coin_amount != 0:
		if last_coin_amount != value:
			coin_increment_animation_label.position = Vector2(0,0)
			var value_to_show: int = value - last_coin_amount
			if value_to_show < 0:
				coin_increment_animation_label.modulate = Color.RED
				coin_increment_animation_label.text = "-" + str(abs(value_to_show))
			else:
				coin_increment_animation_label.modulate = Color.GREEN
				coin_increment_animation_label.text = "+" + str(abs(value_to_show))
			last_coin_amount = value
			if the_tween:
				the_tween.kill()
			the_tween = create_tween()
			the_tween.tween_property(coin_increment_animation_label, "position", Vector2(0,-50), TWEEN_DURATION)
			the_tween.finished.connect(func():
				coin_increment_animation_label.text = "")
	else:
		last_coin_amount = value

func _on_buy_coin_button_textured_pressed() -> void:
	#HttpNetworkManager.request_payment()
	buy_coin_button.emit()
