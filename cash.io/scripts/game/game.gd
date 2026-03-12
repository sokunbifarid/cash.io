extends Node

@onready var in_game_hud_canvas_layer: CanvasLayer = $InGameHUDCanvasLayer
@onready var game_nodes: Node2D = $GameNodes


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_game()
	connect_signal()

func connect_signal() -> void:
	SignalManager.prepare_game.connect(_on_prepare_game)
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.signout_successful.connect(_on_signout_successful)

func _on_signout_successful() -> void:
	hide_game()

func _on_prepare_game() -> void:
	show_game()

func _on_reset_game_signal() -> void:
	hide_game()

func show_game() -> void:
	in_game_hud_canvas_layer.show()
	game_nodes.show()

func hide_game() -> void:
	in_game_hud_canvas_layer.hide()
	game_nodes.hide()
