extends Control

@onready var google_button_textured: TextureButton = $LoginCreateAccountControl/LoginCreatePanelTextureRect/ButtonsVBoxContainer/GoogleButtonTextured
@onready var apple_button_textured: TextureButton = $LoginCreateAccountControl/LoginCreatePanelTextureRect/ButtonsVBoxContainer/AppleButtonTextured
@export var google_sign_in: Node
@export var google_web_sign_in: Node
@export var apple_sign_in: Node
@export var pc_google_auth: Node

var device_name: String = OS.get_name()

func _ready() -> void:
	set_button_status_based_on_device()
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.AUTH
	attempt_silent_auth()



func attempt_silent_auth() -> void:
	if GlobalManager.get_can_silent_auth():
		if OS.get_name() == "Web":
			if google_web_sign_in:
				google_web_sign_in.try_silent_auth()
		else:
			HttpNetworkManager.try_silent_auth()

func set_button_status_based_on_device() -> void:
	if not OS.get_name() == "iOS" or not OS.get_name() == "macOS":
		apple_button_textured.modulate = Color.DIM_GRAY
		apple_button_textured.disabled = true

func _on_google_button_textured_pressed() -> void:
	if device_name == "HTML5" or device_name == "Web":
		if google_web_sign_in:
			google_web_sign_in.sign_in()
		else:
			print("google web sign in node not assigned in auth screen scene")
	elif device_name == "Android":
		if google_sign_in:
			google_sign_in.sign_in()
		else:
			print("google sign in node not assigned in auth screen scene")
	elif device_name == "Windows" or device_name == "windows" or device_name == "macOS":
		if pc_google_auth:
			pc_google_auth.sign_in()
	print("name of device: ", device_name)

func _on_apple_button_textured_pressed() -> void:
	if apple_sign_in:
		apple_sign_in.sign_in()
	else:
		print("apple sign in node not assigned in auth screen scene")


func open_auth() -> void:
	self.show()
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.AUTH
