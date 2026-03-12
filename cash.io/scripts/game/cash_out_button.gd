extends Control

@onready var cashout_button_textured: TextureButton = $CashoutButtonTextured
@onready var enable_texture_progress_bar: TextureProgressBar = $EnableTextureProgressBar

var the_tween: Tween

var duration_to_activate_cashout: float = 30
const TWEEN_DURATION: float = 0.2

func _ready() -> void:
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	SignalManager.cashout_rejected_signal.connect(_on_cashout_rejected_signal)
	set_process(false)

func _on_prepare_game() -> void:
	disable_cashout_button()
	set_process(true)

func _on_match_over_signal(_value: Dictionary, _condition: bool) -> void:
	disable_cashout_button()
	set_process(false)

func _on_cashout_button_textured_pressed() -> void:
	GameHttpNetworkManager.send_cashout_request()

func _on_cashout_rejected_signal(wait_value: float) -> void:
	print("cashout rejected, wait for %s more seconds" % str(wait_value))
	pass

func _process(delta: float) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		var time_left: float = GameHttpNetworkManager.player_starting_time - GameHttpNetworkManager.player_running_time
		if enable_texture_progress_bar.max_value != duration_to_activate_cashout:
			enable_texture_progress_bar.max_value = duration_to_activate_cashout
			enable_texture_progress_bar.value = duration_to_activate_cashout
		if time_left < duration_to_activate_cashout:
			if enable_texture_progress_bar.value != time_left:
				enable_texture_progress_bar.value = time_left
				disable_cashout_button()
		else:
			set_process(false)
			enable_cashout_button()

func disable_cashout_button() -> void:
	if cashout_button_textured.disabled == false:
		cashout_button_textured.disabled = true
		cashout_button_textured.modulate = Color.WEB_GRAY
		cashout_button_textured.scale = Vector2(1,1)
		enable_texture_progress_bar.value = 0

func enable_cashout_button() -> void:
	cashout_button_textured.scale = Vector2(1,1)
	cashout_button_textured.disabled = false
	cashout_button_textured.modulate = Color.WHITE
	enable_texture_progress_bar.value = 0
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(cashout_button_textured, "scale", Vector2(1.2,1.2), TWEEN_DURATION)
	the_tween.tween_property(cashout_button_textured, "scale", Vector2(1,1), TWEEN_DURATION)
