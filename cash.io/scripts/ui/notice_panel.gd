extends Panel

@onready var notice_label: Label = $NoticeLabel
@onready var visible_timer_node: Timer = $VisibleTimer

func _ready() -> void:
	SignalManager.notice.connect(_on_notice)
	self.hide()

func _on_notice(value: String) -> void:
	self.show()
	value = value.capitalize()
	notice_label.text = value
	visible_timer_node.start()

func _on_visible_timer_timeout() -> void:
	self.hide()
