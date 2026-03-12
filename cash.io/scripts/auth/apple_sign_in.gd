extends Node

@export var AUTH_ACTIVE_DURATION: float = 20

var auth_active_timer: Timer = Timer.new()
#var auth_controller: ASAuthorizationController = null

func _ready() -> void:
	if check_os_is_apple():
		auth_active_timer.autostart = false
		auth_active_timer.one_shot = true
		auth_active_timer.wait_time = AUTH_ACTIVE_DURATION
		get_tree().root.add_child.call_deferred(auth_active_timer)
		auth_active_timer.timeout.connect(_on_auth_active_timer_timeout)
		#auth_controller = ASAuthorizationController.new()
		connect_signal()

func connect_signal() -> void:
	#auth_controller.authorization_completed.connect(_on_auth_completed)
	#auth_controller.authorization_failed.connect(_on_auth_failed)
	auth_active_timer.timeout.connect(_on_auth_active_timer_timeout)

func check_os_is_apple() -> bool:
	if OS.get_name() in ["iOS", "macOS"]:
		print("Current device is apple")
		return true
	else:
		printerr("Current device is not apple")
		return false

func sign_in() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if check_os_is_apple():
		#if auth_controller:
			#auth_controller.signin_with_scopes(["full_name", "email"])
		#else:
			#printerr("Apple Sign-in is not available on this platform.")
		pass

func sign_out() -> void:
	var config = ConfigFile.new()
	config.load("user://auth_data.cfg")
	config.set_value("auth", "identity_token", "")
	config.save("user://auth_data.cfg")
	print("Successfully signed out locally.")
	SignalManager.emit_signout_successful_signal()

func _on_auth_completed(credential) -> void:
	print("User ID: ", credential.user)
	print("Email: ", credential.email)
	print("Full Name: ", credential.fullName)

func _on_auth_failed(error_message) -> void:
	print("Apple Sign-in failed: ", error_message)

func _on_auth_active_timer_timeout() -> void:
	sign_out()
	SignalManager.emit_notice_signal("Timeout")
