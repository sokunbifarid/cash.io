extends Control

@onready var input_rect: TouchScreenJoystick = $Input/InputRect
@onready var cash_out_button: Control = $InGameHUDSorterControl/InGameDataHBoxContainer/CashOutButton
@onready var clock_v_box_container: VBoxContainer = $InGameHUDSorterControl/InGameDataHBoxContainer/ClockContentController/ClockVBoxContainer
@onready var clock_value_label: Label = $InGameHUDSorterControl/InGameDataHBoxContainer/ClockContentController/ClockVBoxContainer/ClockValueLabel
@onready var powerup_sorter_v_box_container: GridContainer = $InGameHUDSorterControl/PowerupSorterGridContainer

var the_tween: Tween

var TWEEN_DURATION: float = 0.2
var clock_alert_tween_is_active: bool = false
const MIN_CLOCK_ALERT_VALUE: int = 10

const POWERUP_BUTTON = preload("uid://djc2wflgrn6if")

func _ready() -> void:
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.prepare_game_for_play_again_signal.connect(_on_prepare_game_for_play_again_signal)
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.load_in_game_powersups_signal.connect(_on_load_in_game_powersups_signal)
	hide_hud()
	set_process(false)

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_pressed():
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#input_rect.position = get_local_mouse_position() - input_rect.size/2

func _on_prepare_game_for_play_again_signal() -> void:
	hide_hud()
	set_process(false)
	disable_clock_alert_tween()
	clock_v_box_container.modulate = Color.WHITE

func _on_match_over_signal(_data: Dictionary, condition: bool) -> void:
	hide_hud()
	set_process(false)
	disable_clock_alert_tween()
	clock_v_box_container.modulate = Color.WHITE

func _on_prepare_game() -> void:
	show_hud()
	disable_clock_alert_tween()
	clock_v_box_container.modulate = Color.WHITE
	clock_alert_tween_is_active = false
	clock_value_label.text = "99s"
	await get_tree().create_timer(0.5).timeout
	set_process(true)

func _on_reset_game_signal() -> void:
	for i: Button in powerup_sorter_v_box_container.get_children():
		i.queue_free()

func _on_load_in_game_powersups_signal(payload: Array) -> void:
	spawn_powerup(payload)

func _process(delta: float) -> void:
	set_clock_value()

func set_clock_value() -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		var clock_value: int = int(GameHttpNetworkManager.player_running_time)
		clock_value_label.text = str(clock_value) + "s"
		if clock_value <= MIN_CLOCK_ALERT_VALUE:
			if clock_v_box_container.modulate != Color.RED:
				clock_v_box_container.modulate = Color.RED
				enable_clock_alert_tween()
		else:
			if clock_v_box_container.modulate != Color.WHITE:
				clock_v_box_container.modulate = Color.WHITE
			disable_clock_alert_tween()

func enable_clock_alert_tween() -> void:
	if not clock_alert_tween_is_active:
		clock_alert_tween_is_active = true
		SfxAudioManager.play_clock_ticking_sfx()
		clock_v_box_container.scale = Vector2(1,1)
		if the_tween:
			the_tween.kill()
		the_tween = create_tween()
		the_tween.set_loops()
		the_tween.tween_property(clock_v_box_container, "scale", Vector2(1.2,1.2), TWEEN_DURATION)
		the_tween.tween_property(clock_v_box_container, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_BOUNCE)
		the_tween.tween_interval(1)

func disable_clock_alert_tween() -> void:
	if the_tween:
		the_tween.kill()
	clock_v_box_container.scale = Vector2(1,1)
	SfxAudioManager.stop_clock_ticking_sfx()

func show_hud() -> void:
	input_rect.show()
	cash_out_button.show()
	clock_v_box_container.show()
	powerup_sorter_v_box_container.show()

func hide_hud() -> void:
	input_rect.hide()
	cash_out_button.hide()
	clock_v_box_container.hide()
	powerup_sorter_v_box_container.hide()

#"powerups": [{ "id": "8d6bb1c8-3f7f-4c8c-9ef8-6c5a4f0c1b72", "name": "Turbo Booster", "quantity": 20.0 }, { "id": "2f8a9f3d-0f4c-4b9f-8d1d-2f6a7c1e5b13", "name": "Guardian Shield", "quantity": 11.0 }, { "id": "7b14d3c2-6e5a-4c11-9c7e-3d8f2a6b4e90", "name": "Flash Speed", "quantity": 5.0 }], "remaining_sec": 90.0 } }

func spawn_powerup(data: Array) -> void:
	for j in powerup_sorter_v_box_container.get_children():
		j.queue_free()
	for i: int in range (data.size()):
		var powerup_button: Button = POWERUP_BUTTON.instantiate()
		powerup_sorter_v_box_container.add_child(powerup_button)
		powerup_button.set_powerup_properties(data[i].id, data[i].name, data[i].quantity)
