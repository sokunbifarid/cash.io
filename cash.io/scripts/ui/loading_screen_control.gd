extends Control

@onready var loading_progress_texture_progress_bar: TextureProgressBar = $LoadingPanel/LoadingVBoxContainer/LoadingProgressControl/LoadingProgressTextureProgressBar

var the_tween: Tween
const DURATION: float = 0.5

func _ready() -> void:
	connect_signals()
	disable_loading_screen()
	if GlobalManager.get_can_silent_auth():
		enable_loading_screen()

func connect_signals() -> void:
	SignalManager.open_loading_screen.connect(_on_open_loading_screen)
	SignalManager.signout_successful.connect(_on_signout_successful)

func _on_signout_successful() -> void:
	disable_loading_screen()

func _on_open_loading_screen(value: bool) -> void:
	if value:
		enable_loading_screen()
	else:
		disable_loading_screen()

func enable_loading_screen() -> void:
	if not self.visible:
		self.show()
		loading_progress_texture_progress_bar.value = 0
		the_tween = create_tween().set_loops()
		the_tween.tween_property(
			loading_progress_texture_progress_bar,
			"value",
			loading_progress_texture_progress_bar.max_value,
			DURATION
		)
		the_tween.tween_callback(func():
			loading_progress_texture_progress_bar.value = 0
		)

func disable_loading_screen() -> void:
	if self.visible:
		self.hide()
		if the_tween:
			the_tween.kill()
