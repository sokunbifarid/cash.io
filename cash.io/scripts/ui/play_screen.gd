extends Control

signal play_screen_closed
signal buy_more_powerups

@onready var available_powerups_h_box_container: HBoxContainer = $PlayScreenPanel/PowerupsAvailableVBoxContainer/AvailablePowerupsSorterHBoxContainer/AvailablePowerupsTextureRect/AvailalbePowerupsScrollContainer/AvailablePowerupsHBoxContainer
@onready var ui_buttons_sorter_v_box_container: GridContainer = $PlayScreenPanel/PlayScreenVBoxContainer/PlayerScreenPanelContainer/ScrollContainer/UiButtonsPanelContainer/UIButtonsSorterVBoxContainer

const ROOM_BUTTON_TEXTURED = preload("uid://b2dtkd1a8u6nj")
const AVAILABLE_POWERUPS_PLAY_SCREEN_DATA = preload("uid://bejbntcmb3nim")

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

func _ready() -> void:
	SignalManager.all_rooms_loaded_signal.connect(_on_all_rooms_loaded_signal)
	SignalManager.player_data_loaded_successfully_signal.connect(_on_player_data_loaded_successfully_signal)

func _on_all_rooms_loaded_signal(value: Dictionary) -> void:
	remove_old_rooms_ui_button()
	populate_all_rooms_ui_button(value)

func _on_player_data_loaded_successfully_signal(payload: Dictionary) -> void:
	print("laoded powerups mapped")
	if payload.has("owned_powerups"):
		print("powerups foundd in pocket")
		populate_available_powerups(payload.owned_powerups)

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
	remove_old_rooms_ui_button()
	if payload.has("rooms"):
		var rooms: Array = payload.rooms
		if rooms.size() > 0:
			for i: int in range (rooms.size()):
				print("room count not active: ", i)
				var button: Button = ROOM_BUTTON_TEXTURED.instantiate()
				ui_buttons_sorter_v_box_container.add_child(button)
				button.set_button_data("", str(int(rooms[i].min_stake)) + " Room", rooms[i].id)
				button.room_button_pressed.connect(_on_room_button_pressed)

#"powerups": [{ "id": "8d6bb1c8-3f7f-4c8c-9ef8-6c5a4f0c1b72", "name": "Turbo Booster", "quantity": 20.0 }, { "id": "2f8a9f3d-0f4c-4b9f-8d1d-2f6a7c1e5b13", "name": "Guardian Shield", "quantity": 11.0 }, { "id": "7b14d3c2-6e5a-4c11-9c7e-3d8f2a6b4e90", "name": "Flash Speed", "quantity": 5.0 }], "remaining_sec": 90.0 } }

func populate_available_powerups(owned_powerups: Array) -> void:
	for h in available_powerups_h_box_container.get_children():
		h.queue_free()
	for i: int in range (owned_powerups.size()):
		var powerup: VBoxContainer = AVAILABLE_POWERUPS_PLAY_SCREEN_DATA.instantiate()
		available_powerups_h_box_container.add_child(powerup)
		powerup.set_data(owned_powerups[i].id, owned_powerups[i].quantity)
		print("adding powerups to list")

func _on_play_back_button_textured_pressed() -> void:
	play_screen_closed.emit()
	self.hide()

func _on_room_button_pressed(room_id: String) -> void:
	print("room button pressed to join room")
	#WebsocketMultiplayerRouter.start_websocket_server(room_id)
	GameHttpNetworkManager.send_join_room(room_id)

func _on_buy_more_powerup_button_textured_1_pressed() -> void:
	buy_more_powerups.emit()
