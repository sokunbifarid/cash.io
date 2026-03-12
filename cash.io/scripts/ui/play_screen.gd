extends Control

signal play_screen_closed

@onready var ui_buttons_sorter_v_box_container: GridContainer = $PlayScreenPanel/PlayScreenTextureRect/UIButtonsVBoxContainer/UIButtonsSorterVBoxContainer

const ROOM_BUTTON_TEXTURED = preload("uid://b2dtkd1a8u6nj")

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.all_rooms_loaded_signal.connect(_on_all_rooms_loaded_signal)


func _on_all_rooms_loaded_signal(value: Dictionary) -> void:
	remove_old_rooms_ui_button()
	populate_all_rooms_ui_button(value)

func open_play_screen() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.BUBBLE_ROOMS
	self.show()
	self.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(self, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func remove_old_rooms_ui_button() -> void:
	if ui_buttons_sorter_v_box_container.get_child_count() > 0:
		for i in ui_buttons_sorter_v_box_container.get_children():
			i.queue_free()

func populate_all_rooms_ui_button(payload: Dictionary) -> void:
	if payload.has("rooms"):
		if payload.rooms.size() > 0:
			var rooms: Array = payload.rooms
			for i in rooms:
				var button: TextureButton = ROOM_BUTTON_TEXTURED.instantiate()
				ui_buttons_sorter_v_box_container.add_child(button)
				button.set_button_data("", str(int(i.min_stake)) + " Room", i.id)
				button.room_button_pressed.connect(_on_room_button_pressed)

func _on_play_back_button_textured_pressed() -> void:
	play_screen_closed.emit()
	self.hide()

func _on_room_button_pressed(room_id: String) -> void:
	print("room button pressed to join room")
	GameHttpNetworkManager.number_of_retries_to_join_room = 0
	#WebsocketMultiplayerRouter.start_websocket_server(room_id)
	GameHttpNetworkManager.send_join_room(room_id)
