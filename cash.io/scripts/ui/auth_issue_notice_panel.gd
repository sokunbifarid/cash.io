extends Panel

@onready var auth_issue_label_node: Label = $AuthIssueLabel
@onready var visible_timer_node: Timer = $VisibleTimer

func _ready() -> void:
	SignalManager.issue_with_auth.connect(_on_issue_with_auth)
	self.hide()

func _on_issue_with_auth(value: String) -> void:
	self.show()
	auth_issue_label_node.text = value
	visible_timer_node.start()

func _on_visible_timer_timeout() -> void:
	self.hide()
