extends Node

@onready var auth_screen: Control = $UI/AuthScreen
@onready var menu_holder_screen: Control = $UI/MenuHolderScreen
@onready var ui: CanvasLayer = $UI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signal()
	hide_all_screen()
	open_auth_screen()

func connect_signal() -> void:
	SignalManager.signout_successful.connect(_on_signout_successful)
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.startup_request_data_loaded_successfully.connect(_on_startup_request_data_loaded_successfully)
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)

func _on_signout_successful() -> void:
	hide_all_screen()
	open_auth_screen()

func _on_prepare_game() -> void:
	hide_all_screen()

func _on_reset_game_signal() -> void:
	open_menu()

func _on_startup_request_data_loaded_successfully() -> void:
	open_menu()
	SignalManager.emit_open_loading_screen_signal(false)

func open_menu() -> void:
	hide_all_screen()
	menu_holder_screen.open_menu()

func hide_all_screen() -> void:
	auth_screen.hide()
	menu_holder_screen.hide()

func open_auth_screen() -> void:
	hide_all_screen()
	auth_screen.open_auth()
