extends Control

@onready var reload_button_textured: Button = $ServerIssuePanel/ServerIssueHolderTextureRect/ServerIssueSorterVBoxContainer/ReloadButtonTextured
@onready var server_issue_message_label: Label = $ServerIssuePanel/ServerIssueHolderTextureRect/ServerIssueSorterVBoxContainer/ServerIssueMessageLabel


func _ready() -> void:
	SignalManager.websocket_disconnected.connect(_on_websocket_disconnected)
	SignalManager.websocket_reconnected.connect(_on_websocket_reconnected)
	SignalManager.signout_successful.connect(_on_signout_successful)
	self.hide()

func _on_signout_successful() -> void:
	self.hide()

func try_getting_all_user_data() -> void:
	WebsocketMultiplayerRouter.reconnect_to_online_websocket_server()


func _on_reload_button_textured_pressed() -> void:
	try_getting_all_user_data()
	server_issue_message_label.text = "Reconnecting..."
	reload_button_textured.hide()

func _on_websocket_disconnected() -> void:
	self.show()
	reload_button_textured.show()
	server_issue_message_label.text = "Network\nDisconnected"

func _on_websocket_reconnected() -> void:
	self.hide()
