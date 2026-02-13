extends Control

@export var GOOGLE_WEB_CLIENT_ID: String = "371885959149-q8rjebpl1dc2ho14phuqnj7rn4d202ct.apps.googleusercontent.com"
@export var AUTH_ACTIVE_DURATION: float = 20
@export var google_auth_status_label_node: Label
@export var google_auth_signout_button: TextureButton
@onready var auth_active_timer: Timer = $AuthActiveTimer

var google_sign_in: Object = null

func _ready() -> void:
	auth_active_timer.wait_time = AUTH_ACTIVE_DURATION
	if OS.get_name() == "Android":
		if Engine.has_singleton("GodotGoogleSignIn"):
			google_sign_in = Engine.get_singleton("GodotGoogleSignIn")
			connect_signal()
			google_sign_in.initialize(GOOGLE_WEB_CLIENT_ID)
	else:
		printerr("Current device is not android")

func connect_signal() -> void:
	google_sign_in.connect("sign_in_success", _on_sign_in_success)
	google_sign_in.connect("sign_in_failed", _on_sign_in_failed)
	google_sign_in.connect("sign_out_completed", _on_sign_out_complete)
	SignalManager.google_signout.connect(_on_google_signout)

func sign_in() -> void:
	if google_sign_in:
		google_sign_in.signIn()
		auth_active_timer.start()

func sign_out() -> void:
	if google_sign_in:
		google_sign_in.signOut()

func _on_sign_in_success(id_token: String, email: String, display_name: String) -> void:
	print("Signed in as: ", email)
	print("Display name: ", display_name)
	google_auth_status_label_node.text = "Google Logged In\nSigned in as: {email}\nDisplay name: {display_name}"
	if google_auth_signout_button:
		google_auth_signout_button.show()

func _on_sign_in_failed(error: String) -> void:
	print("Sign-in Failed: ", error)
	google_auth_status_label_node.text = "Google Signed In Failed\nError: {error}"
	SignalManager.emit_issue_with_auth_signal("Issue signing in")

func _on_sign_out_complete() -> void:
	print("Signed Out")
	google_auth_status_label_node.text = "Google Signed out successfully"
	if google_auth_signout_button:
		google_auth_signout_button.hide()

func _on_auth_active_timer_timeout() -> void:
	sign_out()
	SignalManager.emit_issue_with_auth_signal("Timeout")

func _on_google_signout() -> void:
	sign_out()
