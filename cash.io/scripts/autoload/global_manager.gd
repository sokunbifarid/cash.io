extends Node

const SETTINGS_SAVE_PATH: String = "user://settings_save_data.dat"
const USER_SAVE_DATA_PATH: String = "user://user_save_data.dat"

enum GAME_STATE{AUTH, MAINMENU, PROFILE, SETTINGS, DEPOSIT, WITHDRAWAL, SHOP, BUBBLE_ROOMS, BUBBLE_GAME, BUBBLE_GAME_COMPLETED}
var current_game_state: GAME_STATE = GAME_STATE.AUTH

var settings_data: Dictionary = {
	"music_value": 6,
	"sound_effects_value": 6
}

var user_data: Dictionary = {
	"can_silent_auth": false,
	"was_in_match": false,
	"last_match_room_id": ""
}

var current_selected_skin: int = 0
var skins_list_texture_path: Array = [
	"res://imports/ui/Profile/Characters/Skin_1.png",
	"res://imports/ui/Profile/Characters/Skin_2.png",
	"res://imports/ui/Profile/Characters/Skin_3.png",
	"res://imports/ui/Profile/Characters/Skin_4.png",
	"res://imports/ui/Profile/Characters/Skin_5.png",
	"res://imports/ui/Profile/Characters/Skin_6.png",
	"res://imports/ui/Profile/Characters/Skin_7.png",
	"res://imports/ui/Profile/Characters/Skin_8.png",
	"res://imports/ui/Profile/Characters/Skin_9.png",
	"res://imports/ui/Profile/Characters/Skin_10.png",
	"res://imports/ui/Profile/Characters/Skin_11.png",
	"res://imports/ui/Profile/Characters/Skin_12.png"
]

func _ready() -> void:
	load_settings()
	load_user_data()
	SignalManager.signout_successful.connect(_on_signout_successful)

func _on_signout_successful() -> void:
	set_can_silent_auth_user_data(false)

func set_settings(music_value: int, sound_effects_value: int) -> void:
	settings_data.music_value = music_value
	settings_data.sound_effets_value = sound_effects_value

func set_can_silent_auth_user_data(can_silent_auth: bool) -> void:
	user_data.can_silent_auth = can_silent_auth
	save_user_data()

func get_can_silent_auth() -> bool:
	return user_data.can_silent_auth

func set_was_in_match(condition: bool, last_match_room_id: String) -> void:
	user_data.was_in_match = condition
	user_data.last_match_room_id = last_match_room_id
	save_user_data()

func get_was_in_match() -> bool:
	return user_data.was_in_match

func get_last_match_room_id() -> String:
	return user_data.last_match_room_id

func get_music_value() -> int:
	return settings_data.music_value

func get_sound_effect_value() -> int:
	return settings_data.sound_effects_value

func save_user_data() -> void:
	var file: FileAccess = FileAccess.open(USER_SAVE_DATA_PATH, FileAccess.WRITE)
	if file:
		file.store_var(user_data)
		file.close()
	else:
		print("unable to save user data")

func load_user_data() -> void:
	if FileAccess.file_exists(USER_SAVE_DATA_PATH):
		var file: FileAccess = FileAccess.open(USER_SAVE_DATA_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		append_loaded_user_data(data)
	else:
		save_user_data()

func append_loaded_user_data(loaded_data: Dictionary) -> void:
	if loaded_data.has("can_silent_auth"):
		user_data.can_silent_auth = loaded_data.can_silent_auth
	if loaded_data.has("was_in_match"):
		user_data.was_in_match = loaded_data.was_in_match

func save_settings() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(settings_data)
		file.close()
	else:
		print("unable to save settings")

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_SAVE_PATH):
		var file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		append_loaded_settings(data)
	else:
		save_settings()

func append_loaded_settings(loaded_settings: Dictionary) -> void:
	if loaded_settings.has("music_value"):
		settings_data.music_value = loaded_settings.music_value
	if loaded_settings.has("sound_effects_value"):
		settings_data.sound_effects_value = loaded_settings.sound_effects_value

func _notification(what):
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("App minimized or sent to background")
		get_tree().paused = true
	
	if what == NOTIFICATION_APPLICATION_RESUMED:
		print("App returned to foreground")
		get_tree().paused = false

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Application is about to close")
		WebsocketMultiplayerRouter.close_websocket_client()
