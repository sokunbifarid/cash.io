extends Control

func _ready() -> void:
	SignalManager.error_getting_user_data_signal.connect(_on_error_getting_user_data_signal)
	SignalManager.signout_successful.connect(_on_signout_successful)
	self.hide()

func _on_signout_successful() -> void:
	self.hide()

func try_getting_all_user_data() -> void:
	HttpNetworkManager.request_http_user_data()

func _on_reload_button_textured_pressed() -> void:
	try_getting_all_user_data()
	self.hide()

func _on_error_getting_user_data_signal() -> void:
	self.show()
