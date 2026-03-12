extends Node2D


@onready var camera_2d: Camera2D = $Camera2D
@onready var character_data_holder_node: Node2D = $CharacterDataHolderNode
@onready var name_label: Label = $CharacterDataHolderNode/CharacterOverHeadUI/NameLabel
@onready var coin_value_label: Label = $CharacterDataHolderNode/CharacterOverHeadUI/CoinHBoxContainer/CoinValueLabel
@onready var character_texture: Sprite2D = $CharacterDataHolderNode/CharacterTexture
@onready var character_skin_texture: Sprite2D = $CharacterDataHolderNode/CharacterSkinTexture
@onready var coin_texture_rect: TextureRect = $CharacterDataHolderNode/CharacterOverHeadUI/CoinHBoxContainer/CoinTextureRect
@onready var burst_cpu_particles_2d: CPUParticles2D = $BurstCPUParticles2D

var mouse_in_use_by_character: bool = false
var is_character_enabled: bool = false

var current_player_is_authority: bool = false
var delta_frame: float = 0
var direction: Vector2 = Vector2.ZERO
var current_coin: int = 0
var current_name: String = ""
var next_pos: Vector2 = Vector2.ZERO
const SPEED: float = 1500#600
var last_mouse_pressed_position: Vector2 = Vector2.ZERO

var data_record: Dictionary = {
	"starting_coin": 0,
	"starting_mass": 0,
	}

func _ready() -> void:
	set_process(false)
	set_process_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		if last_mouse_pressed_position == Vector2.ZERO:
			last_mouse_pressed_position = get_local_mouse_position()
	elif Input.is_action_just_released("mouse_left"):
		last_mouse_pressed_position = Vector2.ZERO
		direction = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if is_character_enabled and current_player_is_authority:
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
			#next_pos.x = self.global_position.x + direction.x * SPEED * 0.8
		elif Input.is_action_pressed("ui_right"):
			direction.x = 1
			#next_pos.x = self.global_position.x + direction.x * SPEED * 0.8
		else:
			direction.x = 0
		if Input.is_action_pressed("ui_up"):
			direction.y = -1
			#next_pos.y = self.global_position.y + direction.y * SPEED * 0.8
		elif Input.is_action_pressed("ui_down"):
			direction.y = 1
			#next_pos.y = self.global_position.y + direction.y * SPEED
		else:
			direction.y = 0

func set_data(pos: Vector2, mass: float, coin: int) -> void:
	if is_character_enabled:
		if name_label.label_settings.font_size != mass * 6.0:
			name_label.label_settings.font_size = mass * 6.0
		if coin_value_label.label_settings.font_size != mass * 6.0:
			coin_value_label.label_settings.font_size = mass * 6.0
		if coin_texture_rect.custom_minimum_size != Vector2(mass, mass) * 5:
			coin_texture_rect.custom_minimum_size = Vector2(mass, mass) * 5
		if character_skin_texture.scale != Vector2(mass,mass)/2:
			character_skin_texture.scale = Vector2(mass,mass)/2
		if character_texture.scale != Vector2(mass,mass)/2:
			character_texture.scale = Vector2(mass,mass)/2
		#mass = mass/20
		#character_data_holder_node.global_scale = Vector2(mass, mass)
		if current_coin != coin:
			coin_value_label.text = str(int(coin))
			current_coin = coin
		if next_pos != pos:
			next_pos = pos
		#if color_value != "":
			#if character_texture.self_modulate != Color(color_value):
				#character_texture.self_modulate = color_value
		self.global_position = self.global_position.move_toward(next_pos, SPEED * delta_frame)
		print("player position is updating")
		print("player position updated by server: ", pos)

func set_force_data(pos: Vector2, mass: float, coin: int, appearance: String = "", player_name: String = "") -> void:
	name_label.label_settings.font_size = mass * 5.0
	coin_value_label.label_settings.font_size = mass * 5.0
	coin_texture_rect.scale = Vector2(mass, mass)
	character_skin_texture.scale = Vector2(mass,mass)/2
	character_texture.scale = Vector2(mass,mass)/2
		#mass = mass/20
		#character_data_holder_node.global_scale = Vector2(mass, mass)
	coin_value_label.text = str(int(coin))
		#if color_value != "":
			#if character_texture.self_modulate != Color(color_value):
				#character_texture.self_modulate = color_value
	current_coin = coin
	current_name = player_name
	name_label.text = player_name
	self.global_position = pos
	if not self.visible:
		self.show()

func _process(delta: float) -> void:
	if is_character_enabled:
		delta_frame = delta
		if last_mouse_pressed_position != Vector2.ZERO:
			var next_mouse_pressed_position: Vector2 = get_local_mouse_position()
			direction = ((last_mouse_pressed_position - next_mouse_pressed_position) * last_mouse_pressed_position.distance_to(next_mouse_pressed_position)) .normalized()
		if direction != Vector2.ZERO:
			print("direction is being sent as != 0")
			GameHttpNetworkManager.send_player_movement_input(direction.x, direction.y)
func character_enabled(is_authority_player: bool = false) -> void:
	is_character_enabled = true
	set_process(true)
	set_process_input(true)
	current_player_is_authority = is_authority_player
	if is_authority_player:
		camera_2d.enabled = true

#call this when you figure out how the characters that have left the match or have been killed are returned
func character_disabled() -> void:
	print("character disabled")
	burst_cpu_particles_2d.emitting = true
	is_character_enabled = false
	character_data_holder_node.hide()

func _on_burst_cpu_particles_2d_finished() -> void:
	queue_free()
