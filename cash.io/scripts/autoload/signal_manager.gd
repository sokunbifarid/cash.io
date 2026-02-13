extends Node

signal open_loading_screen(condition: bool)
signal issue_with_auth(value: String)
signal apple_signout
signal google_signout

func emit_open_loading_screen_signal(value: bool) -> void:
	open_loading_screen.emit(value)

func emit_issue_with_auth_signal(value: String) -> void:
	issue_with_auth.emit(value)

func emit_apple_signout_signal() -> void:
	apple_signout.emit()

func emit_google_signout_signal() -> void:
	google_signout.emit()
