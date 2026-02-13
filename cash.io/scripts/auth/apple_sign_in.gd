extends Control

@export var AUTH_ACTIVE_DURATION: float = 20
@onready var auth_active_timer: Timer = $AuthActiveTimer

var auth_controller: ASAuthorizationController = null

func _ready() -> void:
	if OS.get_name() in ["iOS", "macOS"]:
		auth_controller = ASAuthorizationController.new()
		connect_signal()
	else:
		printerr("Current device is not an apple device")

func connect_signal() -> void:
	auth_controller.authorization_completed.connect(_on_auth_completed)
	auth_controller.authorization_failed.connect(_on_auth_failed)
	auth_active_timer.timeout.connect(_on_auth_active_timer_timeout)
	SignalManager.apple_signout.connect(_on_apple_signout)

func sign_in() -> void:
	if auth_controller:
		auth_controller.signin_with_scopes(["full_name", "email"])
	else:
		printerr("Apple Sign-in is not available on this platform.")

func sign_out() -> void:
	var config = ConfigFile.new()
	config.load("user://auth_data.cfg")
	config.set_value("auth", "identity_token", "")
	config.save("user://auth_data.cfg")
	print("Successfully signed out locally.")

func _on_auth_completed(credential) -> void:
	print("User ID: ", credential.user)
	print("Email: ", credential.email)
	print("Full Name: ", credential.fullName)

func _on_auth_failed(error_message) -> void:
	print("Apple Sign-in failed: ", error_message)

func _on_auth_active_timer_timeout() -> void:
	sign_out()
	SignalManager.emit_issue_with_auth_signal("Timeout")

func _on_apple_signout() -> void:
	sign_out()
