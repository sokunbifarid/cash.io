extends Control

@onready var input_rect: TouchScreenJoystick = $Input/InputRect
@onready var cash_out_button: Control = $InGameHUDSorterControl/InGameDataHBoxContainer/CashOutButton
@onready var clock_v_box_container: VBoxContainer = $InGameHUDSorterControl/InGameDataHBoxContainer/ClockContentController/ClockVBoxContainer
@onready var clock_value_label: Label = $InGameHUDSorterControl/InGameDataHBoxContainer/ClockContentController/ClockVBoxContainer/ClockValueLabel

var the_tween: Tween

var TWEEN_DURATION: float = 0.2
var clock_alert_tween_is_active: bool = false
const MIN_CLOCK_ALERT_VALUE: int = 10


func _ready() -> void:
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	SignalManager.prepare_game.connect(_on_prepare_game)
	hide_hud()
	set_process(false)

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_pressed():
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#input_rect.position = get_local_mouse_position() - input_rect.size/2

func _on_match_over_signal(_data: Dictionary, condition: bool) -> void:
	hide_hud()
	set_process(false)
	disable_clock_alert_tween()
	clock_v_box_container.modulate = Color.WHITE

func _on_prepare_game() -> void:
	show_hud()
	set_process(true)
	disable_clock_alert_tween()
	clock_v_box_container.modulate = Color.WHITE
	clock_alert_tween_is_active = false

func _process(delta: float) -> void:
	set_clock_value()

func set_clock_value() -> void:
	var clock_value: int = int(GameHttpNetworkManager.player_running_time)
	clock_value_label.text = str(clock_value) + "s"
	if clock_value <= MIN_CLOCK_ALERT_VALUE:
		if clock_v_box_container.modulate != Color.RED:
			clock_v_box_container.modulate = Color.RED
			enable_clock_alert_tween()
	else:
		if clock_v_box_container.modulate != Color.WHITE:
			clock_v_box_container.modulate = Color.WHITE

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

func hide_hud() -> void:
	input_rect.hide()
	cash_out_button.hide()
	clock_v_box_container.hide()
