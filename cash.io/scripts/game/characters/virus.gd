extends Sprite2D

const SPEED: float = 1500
var delta_frame: float = 0

func set_data(pos: Vector2, mass: float, color_value: String = "") -> void:
	mass = mass/2
	self.scale = Vector2(mass, mass)
	if color_value != "":
		if self.self_modulate != Color(color_value):
			self.self_modulate = color_value

	self.global_position = self.global_position.move_toward(pos, SPEED * delta_frame)

func set_force_data(pos: Vector2, mass: float, color_value: String = "") -> void:
	mass = mass/2
	self.scale = Vector2(mass, mass)
	if color_value != "":
		if self.self_modulate != Color(color_value):
			self.self_modulate = color_value
	self.global_position = pos
	if not self.visible:
		self.show()

func _process(delta: float) -> void:
	delta_frame = delta
