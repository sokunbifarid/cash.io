extends TextureRect


var the_tween: Tween

const TWEEN_DURATION: float = 1

func _ready() -> void:
	SignalManager.websocket_connection_is_poor_signal.connect(_on_websocket_connection_is_poor_signal)
	SignalManager.match_over_signal.connect(_on_match_over_signal)
	disable_poor_connection()

func _on_match_over_signal(_value: Dictionary, condition: bool) -> void:
	disable_poor_connection()

func _on_websocket_connection_is_poor_signal(condition: bool) -> void:
	if condition:
		enable_poor_connection()
	else:
		disable_poor_connection()

func enable_poor_connection() -> void:
	self.modulate = Color(1.0, 0.0, 0.0, 1.0)
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.set_loops()
	the_tween.tween_property(self, "modulate", Color(1.0, 0.0, 0.0, 0.3), TWEEN_DURATION)
	the_tween.tween_property(self, "modulate", Color(1.0, 0.0, 0.0, 1.0), TWEEN_DURATION)
	the_tween.tween_interval(1)
	print("poor connection enabled")

func disable_poor_connection() -> void:
	self.modulate = Color(1.0, 0.0, 0.0, 0.0)
	if the_tween:
		the_tween.kill()
