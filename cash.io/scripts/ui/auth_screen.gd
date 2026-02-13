extends Control

@export var google_signin_node: Control
@export var apple_signin_node: Control

func _on_google_button_textured_pressed() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if google_signin_node:
		google_signin_node.sign_in()
	else:
		print("Google signin node not assigned in auth screen")

func _on_apple_button_textured_pressed() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	if apple_signin_node:
		apple_signin_node.sign_in()
	else:
		print("Apple signin node not assigned in auth screen")


func _on_google_signout_button_textured_1_pressed() -> void:
	google_signin_node.sign_out()
