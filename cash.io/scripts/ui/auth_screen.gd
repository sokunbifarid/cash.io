extends Control

@onready var google_button_textured: Button = $LoginCreateAccountControl/LoginCreatePanelTextureRect/ButtonsVBoxContainer/GoogleButtonTextured
@onready var apple_button_textured: Button = $LoginCreateAccountControl/LoginCreatePanelTextureRect/ButtonsVBoxContainer/AppleButtonTextured
@export var mobile_sign_in: Node
@export var web_sign_in: Node
@export var pc_google_auth: Node

var device_name: String = OS.get_name()

func _ready() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.AUTH
	attempt_silent_auth()

func attempt_silent_auth() -> void:
	if GlobalManager.get_can_silent_auth():
		if OS.get_name() == "Web":
			if web_sign_in:
				web_sign_in.try_silent_auth()
		else:
			HttpNetworkManager.try_silent_auth()

func _on_google_button_textured_pressed() -> void:
	if device_name == "HTML5" or device_name == "Web":
		if web_sign_in:
			web_sign_in.google_web_sign_in()
		else:
			print("google web sign in node not assigned in auth screen scene")
	elif device_name == "Android" or device_name == "iOS":
		if mobile_sign_in:
			mobile_sign_in.google_sign_in()
		else:
			print("google sign in node not assigned in auth screen scene")

	elif device_name == "Windows" or device_name == "windows" or device_name == "macOS":
		if pc_google_auth:
			pc_google_auth.google_sign_in()
			print("this worked on button press")
	print("name of device: ", device_name)

func _on_apple_button_textured_pressed() -> void:
	if device_name == "HTML5" or device_name == "Web":
		if web_sign_in:
			web_sign_in.apple_web_sign_in()
		else:
			print("apple web sign in node not assigned in auth screen scene")
	elif device_name == "Android" or device_name == "iOS":
		if mobile_sign_in:
			mobile_sign_in.ios_sign_in()
		else:
			print("iOS sign in node not assigned in auth screen scene")
	elif device_name == "Windows":
		if pc_google_auth:
			pc_google_auth.apple_sign_in()
	else:
		print("apple sign in node not assigned in auth screen scene")

func open_auth() -> void:
	self.show()
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.AUTH
