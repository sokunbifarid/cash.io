extends Node2D


@onready var camera_2d: Camera2D = $Camera2D
@onready var character_data_holder_node: Node2D = $CharacterDataHolderNode
@onready var name_label: Label = $CharacterDataHolderNode/CharacterOverHeadUI/NameLabel
@onready var coin_value_label: Label = $CharacterDataHolderNode/CharacterOverHeadUI/CoinHBoxContainer/CoinValueLabel
@onready var character_texture: Sprite2D = $CharacterDataHolderNode/CharacterTexture
@onready var coin_texture_rect: TextureRect = $CharacterDataHolderNode/CharacterOverHeadUI/CoinHBoxContainer/CoinTextureRect
@onready var burst_cpu_particles_2d: CPUParticles2D = $BurstCPUParticles2D
@onready var skin_texture_clip_texture_rect: TextureRect = $CharacterDataHolderNode/SkinTextureClipTextureRect
@onready var skin_texture_rect: TextureRect = $CharacterDataHolderNode/SkinTextureClipTextureRect/SkinTextureRect

var mouse_in_use_by_character: bool = false
var is_character_enabled: bool = false

var current_player_is_authority: bool = false
var delta_frame: float = 0
var direction: Vector2 = Vector2.ZERO
var current_coin: int = 0
var current_name: String = ""
var next_pos: Vector2 = Vector2.ZERO
const SPEED: float = 1000#1500#600
var last_mouse_pressed_position: Vector2 = Vector2.ZERO
var player_client_side_reconsilation_queue_input: Array = []
var player_client_side_recosilation_sequence: int = 0
var using_client_side_prediction: bool = false

const SKIN_PATH: String = "res://assets/game/character/avatars/"
const SKIN_DOMAIN: String = ".png"

var data_record: Dictionary = {
	"starting_coin": 0,
	"starting_mass": 0,
	}

func _ready() -> void:
	set_process(false)
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if is_character_enabled and current_player_is_authority:
		if Input.is_action_pressed("ui_left"):
			direction.x = -1
		elif Input.is_action_pressed("ui_right"):
			direction.x = 1
		else:
			direction.x = 0
		if Input.is_action_pressed("ui_up"):
			direction.y = -1
		elif Input.is_action_pressed("ui_down"):
			direction.y = 1
		else:
			direction.y = 0

func set_data(pos: Vector2, mass: float, coin: int, input_sequence: int) -> void:
	if is_character_enabled:
		#if name_label.label_settings.font_size != mass * 6.0:
			#name_label.label_settings.font_size = mass * 6.0
		#if coin_value_label.label_settings.font_size != mass * 6.0:
			#coin_value_label.label_settings.font_size = mass * 6.0
		#if coin_texture_rect.custom_minimum_size != Vector2(mass, mass) * 5:
			#coin_texture_rect.custom_minimum_size = Vector2(mass, mass) * 5
		#if skin_texture_clip_texture_rect.visible:
			#if skin_texture_clip_texture_rect.scale != Vector2(mass,mass)/2:
				#skin_texture_clip_texture_rect.scale = Vector2(mass,mass)/2
		#if character_texture.scale != Vector2(mass,mass)/2:
			#character_texture.scale = Vector2(mass,mass)/2

		if skin_texture_clip_texture_rect.visible:
			if skin_texture_clip_texture_rect.scale != Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y):
				skin_texture_clip_texture_rect.scale = Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y)
		if character_texture.scale != Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y):
			character_texture.scale = Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y)

		if current_coin != coin:
			coin_value_label.text = str(int(coin))
			current_coin = coin
		if not using_client_side_prediction:
			if next_pos != pos:
				next_pos = pos
		else:
			if self.global_position != next_pos:
				self.global_position = next_pos
			player_client_side_reconsilation_queue_input = player_client_side_reconsilation_queue_input.filter(func(p):
				return p.sequence > player_client_side_recosilation_sequence)
			for i in player_client_side_reconsilation_queue_input:
				next_pos = i.pos
		#self.global_position = self.global_position.move_toward(next_pos, SPEED * delta_frame)
		#print("player position is updating")
		#print("player position updated by server: ", pos)

func set_force_data(pos: Vector2, mass: float, coin: int, appearance: String = "", player_name: String = "") -> void:
	#name_label.label_settings.font_size = mass * 6.0
	#coin_value_label.label_settings.font_size = mass * 6.0
	#coin_texture_rect.custom_minimum_size = Vector2(mass, mass) * 5
	if skin_texture_clip_texture_rect.visible:
		if skin_texture_clip_texture_rect.scale != Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y):
			skin_texture_clip_texture_rect.scale = Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y)
	if character_texture.scale != Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y):
		character_texture.scale = Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y)
	current_coin = coin
	current_name = player_name
	name_label.text = player_name
	next_pos = pos
	appearance = GlobalManager.player_selected_skin_id
	if appearance != "":
		coin_value_label.label_settings.font_color = Color.WHITE
		name_label.label_settings.font_color = Color.WHITE
		skin_texture_clip_texture_rect.show()
		skin_texture_rect.texture = ResourceLoader.load(SKIN_PATH + appearance + SKIN_DOMAIN)
	else:
		skin_texture_clip_texture_rect.hide()
		coin_value_label.label_settings.font_color = Color.BLACK
		name_label.label_settings.font_color = Color.BLACK
	self.global_position = pos
	if not self.visible:
		self.show()

func set_camera_limit(bounds: Vector2 = Vector2.ZERO) -> void:
	const LIMIT_OFFSET: float = 100
	if bounds != Vector2.ZERO:
		camera_2d.limit_bottom = bounds.x + LIMIT_OFFSET/2
		camera_2d.limit_right = bounds.y + LIMIT_OFFSET
		camera_2d.limit_left = 0 - LIMIT_OFFSET
		camera_2d.limit_top = 0 - LIMIT_OFFSET/2

func _process(delta: float) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		if is_character_enabled:
			delta_frame = delta
			touch_input()
			if using_client_side_prediction:
				client_side_reconsilation()
			else:
				if direction != Vector2.ZERO:
					#print("direction is being sent as != 0")
					GameHttpNetworkManager.send_player_movement_input(direction.x, direction.y)
			self.global_position = self.global_position.move_toward(next_pos, SPEED * delta_frame)

func touch_input() -> void:
	if current_player_is_authority:
		if Input.is_action_just_pressed("mouse_left"):
			if last_mouse_pressed_position == Vector2.ZERO:
				last_mouse_pressed_position = get_local_mouse_position()
		elif Input.is_action_just_released("mouse_left"):
			last_mouse_pressed_position = Vector2.ZERO
			direction = Vector2.ZERO
		if last_mouse_pressed_position != Vector2.ZERO:
			var next_mouse_pressed_position: Vector2 = get_local_mouse_position()
			direction = ((next_mouse_pressed_position - last_mouse_pressed_position) * last_mouse_pressed_position.distance_to(next_mouse_pressed_position)).normalized()

func client_side_reconsilation() -> void:
	if direction != Vector2.ZERO:
		next_pos = self.global_position + (direction * SPEED)
		player_client_side_recosilation_sequence += 1
		var queue_input: Dictionary = {"pos": next_pos, "sequence": player_client_side_recosilation_sequence}
		player_client_side_reconsilation_queue_input.append(queue_input)
		GameHttpNetworkManager.send_player_movement_input(queue_input.dir.x, queue_input.dir.y, player_client_side_recosilation_sequence)
		self.global_position.move_toward(next_pos, SPEED * delta_frame)

func character_enabled(is_authority_player: bool = false,  bounds: Vector2 = Vector2.ZERO) -> void:
	is_character_enabled = true
	set_process(true)
	set_process_input(true)
	current_player_is_authority = is_authority_player
	if is_authority_player:
		camera_2d.enabled = true
		set_camera_limit(bounds)

#call this when you figure out how the characters that have left the match or have been killed are returned
func character_disabled() -> void:
	#print("character disabled")
	burst_cpu_particles_2d.emitting = true
	is_character_enabled = false
	character_data_holder_node.hide()

func _on_burst_cpu_particles_2d_finished() -> void:
	queue_free()
