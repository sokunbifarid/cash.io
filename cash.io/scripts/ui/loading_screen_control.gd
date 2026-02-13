extends Control

@onready var loading_label: Label = $LoadingPanel/LoadingLabel

var the_tween: Tween

func _ready() -> void:
	connect_signals()
	disable_loading_screen()

func connect_signals() -> void:
	SignalManager.open_loading_screen.connect(_on_open_loading_screen)

func _on_open_loading_screen(value: bool) -> void:
	if value:
		enable_loading_screen()
	else:
		disable_loading_screen()

func enable_loading_screen() -> void:
	const DURATION: float = 0.25
	self.show()
	the_tween = create_tween()
	the_tween.tween_property(loading_label, "text", "Loading", DURATION)
	the_tween.tween_property(loading_label, "text", "Loading.", DURATION)
	the_tween.tween_property(loading_label, "text", "Loading..", DURATION)
	the_tween.tween_property(loading_label, "text", "Loading...", DURATION)
	the_tween.set_loops()

func disable_loading_screen() -> void:
	self.hide()
	if the_tween:
		the_tween.kill()
