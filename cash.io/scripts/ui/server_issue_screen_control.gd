extends Control

func _ready() -> void:
	SignalManager.websocket_disconnected.connect(_on_websocket_disconnected)
	SignalManager.websocket_reconnected.connect(_on_websocket_reconnected)
	SignalManager.signout_successful.connect(_on_signout_successful)
	self.hide()

func _on_signout_successful() -> void:
	self.hide()

func try_getting_all_user_data() -> void:
	#NetworkManager.nakama_connect_to_web_socket_server()
	WebsocketMultiplayerRouter.reconnect_to_online_websocket_server()

func _on_reload_button_textured_pressed() -> void:
	try_getting_all_user_data()
	self.hide()

func _on_websocket_disconnected() -> void:
	self.show()

func _on_websocket_reconnected() -> void:
	self.hide()
