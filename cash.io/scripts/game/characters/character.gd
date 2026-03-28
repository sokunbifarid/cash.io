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
@onready var coin_bonus_h_box_container: HBoxContainer = $CharacterDataHolderNode/CharacterOverHeadUI/CoinBonusHBoxContainer
@onready var coin_bonus_value_label: Label = $CharacterDataHolderNode/CharacterOverHeadUI/CoinBonusHBoxContainer/CoinBonusValueLabel
@onready var character_shield: Sprite2D = $CharacterDataHolderNode/CharacterShield

var mouse_in_use_by_character: bool = false
var is_character_enabled: bool = false

var current_player_is_authority: bool = false
var superior_killing_character: CharacterBody2D = null
var delta_frame: float = 0
var direction: Vector2 = Vector2.ZERO
var current_coin: int = 0
var current_name: String = ""
var next_pos: Vector2 = Vector2.ZERO
var next_character_texture_scale: Vector2 = Vector2.ZERO
var next_skin_texture_scale: Vector2 = Vector2.ZERO
var next_shield_scale: Vector2 = Vector2.ZERO
var current_speed: float = 1000
const DEFAULT_SPEED: float = 1000#1500#600
const HIGH_SPEED: float = 2000
var last_mouse_pressed_position: Vector2 = Vector2.ZERO
var using_client_side_prediction: bool = false#true
const POSITION_CLIENT_SERVER_RECONSILATION_MARGIN: float = 1500.0

const STANDARD_LERP_SPEED: float = 1
const SKIN_PATH: String = "res://assets/game/character/avatars/"
const SKIN_DOMAIN: String = ".png"


var data_record: Dictionary = {
	"starting_coin": 0,
	"starting_mass": 0,
	}

func _ready() -> void:
	set_process(false)
	set_process_input(false)
	disable_powerups()
	#SignalManager.player_shield_protection_on_join_match_firstime_signal.connect(_on_player_shield_protection_on_join_match_firstime_signal)
#
#func _on_player_shield_protection_on_join_match_firstime_signal() -> void:
	#if current_player_is_authority:
		#enable_shield()

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
		#print("direction being mapped based on input: ", direction)

func set_data(pos: Vector2, mass: float, coin: int) -> void:
	if is_character_enabled:
		if skin_texture_clip_texture_rect.visible:
			if next_skin_texture_scale != Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y):
				next_skin_texture_scale = Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y)
		if next_character_texture_scale != Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y):
			next_character_texture_scale = Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y)
		if next_shield_scale != Vector2(mass / character_shield.texture.get_size().x, mass / character_shield.texture.get_size().y) * 1.5:
			next_shield_scale = Vector2(mass / character_shield.texture.get_size().x, mass / character_shield.texture.get_size().y) * 1.5

		if current_coin != coin:
			coin_value_label.text = str(int(coin))
			current_coin = coin
		if not using_client_side_prediction:
			if next_pos != pos:
				next_pos = pos
		else:
			if next_pos.distance_to(pos) < POSITION_CLIENT_SERVER_RECONSILATION_MARGIN:
				if next_pos != pos:
					next_pos = pos
					self.global_position = self.global_position.move_toward(next_pos, current_speed * 10 * delta_frame)


func set_force_data(pos: Vector2, mass: float, coin: int, appearance: String = "", player_name: String = "") -> void:
	current_coin = coin
	current_name = player_name
	name_label.text = player_name
	next_pos = pos
	appearance = GlobalManager.player_selected_skin_id
	if appearance != "":
		coin_value_label.label_settings.font_color = Color.WHITE
		coin_bonus_value_label.label_settings.font_color = Color.WHITE
		name_label.label_settings.font_color = Color.WHITE
		skin_texture_clip_texture_rect.show()
		skin_texture_rect.texture = ResourceLoader.load(SKIN_PATH + appearance + SKIN_DOMAIN)
	else:
		skin_texture_clip_texture_rect.hide()
		coin_value_label.label_settings.font_color = Color.BLACK
		coin_bonus_value_label.label_settings.font_color = Color.WHITE
		name_label.label_settings.font_color = Color.BLACK
	if skin_texture_clip_texture_rect.visible:
		skin_texture_clip_texture_rect.scale = Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y)
	character_texture.scale = Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y)
	character_shield.scale = Vector2(mass / character_shield.texture.get_size().x, mass / character_shield.texture.get_size().y) * 1.5
	character_shield.scale = Vector2(mass / character_shield.texture.get_size().x, mass / character_shield.texture.get_size().y) * 1.5
	next_skin_texture_scale = Vector2(mass/skin_texture_clip_texture_rect.size.x,mass/skin_texture_clip_texture_rect.size.y)
	next_character_texture_scale = Vector2(mass / character_texture.texture.get_size().x,mass / character_texture.texture.get_size().y)
	next_shield_scale = Vector2(mass / character_shield.texture.get_size().x, mass / character_shield.texture.get_size().y) * 1.5
	coin_value_label.text = str(int(coin))
	self.global_position = pos
	if not self.visible:
		self.show()

func set_camera_limit(bounds: Vector2 = Vector2.ZERO) -> void:
	if bounds != Vector2.ZERO:
		const LIMIT_OFFSET: float = 100
		if camera_2d.limit_bottom != bounds.x + LIMIT_OFFSET/2:
			camera_2d.limit_bottom = bounds.x + LIMIT_OFFSET/2
		if camera_2d.limit_right != bounds.y + LIMIT_OFFSET:
			camera_2d.limit_right = bounds.y + LIMIT_OFFSET
		if camera_2d.limit_left != 0 - LIMIT_OFFSET:
			camera_2d.limit_left = 0 - LIMIT_OFFSET
		if camera_2d.limit_top != 0 - LIMIT_OFFSET/2:
			camera_2d.limit_top = 0 - LIMIT_OFFSET/2

func _process(delta: float) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.BUBBLE_GAME:
		if is_character_enabled:
			set_camera_limit(GameHttpNetworkManager.room_bound)
			delta_frame = delta
			touch_input()
			if using_client_side_prediction:
				client_side_reconsilation()
			else:
				if direction != Vector2.ZERO:
					GameHttpNetworkManager.send_player_movement_input(direction.x, direction.y)
			self.global_position = self.global_position.move_toward(next_pos, current_speed * delta_frame)
			character_texture.scale = lerp(character_texture.scale, next_character_texture_scale, STANDARD_LERP_SPEED)
			character_shield.scale = lerp(character_shield.scale, next_shield_scale, STANDARD_LERP_SPEED)
			if skin_texture_clip_texture_rect.visible:
				skin_texture_clip_texture_rect.scale = lerp(skin_texture_clip_texture_rect.scale, next_skin_texture_scale, STANDARD_LERP_SPEED)
		else:
			if superior_killing_character:
				self.position = lerp(self.position, superior_killing_character.position, current_speed * 10)
				if self.position.distance_to(superior_killing_character.position) <= current_speed * 10:
					self.position = superior_killing_character.position
					character_disable_initializer()

func touch_input() -> void:
	if current_player_is_authority:
		if Input.is_action_just_pressed("mouse_left"):
			if get_local_mouse_position() < Vector2(get_window().size.x - get_window().size.x / 10, get_window().size.y - get_window().size.y / 8):
				if last_mouse_pressed_position == Vector2.ZERO:
					last_mouse_pressed_position = get_local_mouse_position()
		elif Input.is_action_just_released("mouse_left"):
			last_mouse_pressed_position = Vector2.ZERO
			direction = Vector2.ZERO
		if last_mouse_pressed_position != Vector2.ZERO:
			var next_mouse_pressed_position: Vector2 = get_local_mouse_position()
			#direction = ((next_mouse_pressed_position - last_mouse_pressed_position) * last_mouse_pressed_position.distance_to(next_mouse_pressed_position))#.normalized()
			direction = ((next_mouse_pressed_position - last_mouse_pressed_position)).normalized()# * last_mouse_pressed_position.distance_to(next_mouse_pressed_position))#.normalized()
			direction = direction.sign()
			#print("direction being mapped based on input: ", direction)

func client_side_reconsilation() -> void:
	if direction != Vector2.ZERO:
		next_pos = self.global_position + (direction * current_speed)
		self.global_position.move_toward(next_pos, current_speed * delta_frame)

func character_enabled(is_authority_player: bool = false,  bounds: Vector2 = Vector2.ZERO) -> void:
	is_character_enabled = true
	set_process(true)
	set_process_input(true)
	current_player_is_authority = is_authority_player
	current_speed = DEFAULT_SPEED
	if is_authority_player:
		camera_2d.enabled = true
		set_camera_limit(bounds)
	else:
		if using_client_side_prediction:
			using_client_side_prediction = false

#call this when you figure out how the characters that have left the match or have been killed are returned
func character_disabled() -> void:
	#print("character disabled")
	is_character_enabled = false
	await get_tree().create_timer(0.5).timeout
	if superior_killing_character == null:
		character_disable_initializer()

func character_disable_initializer() -> void:
	burst_cpu_particles_2d.emitting = true
	character_data_holder_node.hide()
	disable_powerups()
	if current_player_is_authority:
		SfxAudioManager.play_character_burst_sfx()

func death_tween_to_player(the_character: CharacterBody2D) -> void:
	if the_character.is_character_enabled:
		superior_killing_character = the_character

func disable_powerups() -> void:
	coin_bonus_h_box_container.hide()
	character_shield.hide()

func enable_shield() -> void:
	character_shield.show()
	print("character shield is visible")

func disable_shield() -> void:
	character_shield.hide()
	print("characer shield is not visible")

func enable_coin_bonus() -> void:
	coin_bonus_h_box_container.show()

func disable_coin_bonus() -> void:
	coin_bonus_h_box_container.hide()

func enable_high_speed() -> void:
	current_speed = HIGH_SPEED

func disable_high_speed() -> void:
	current_speed = DEFAULT_SPEED

func _on_burst_cpu_particles_2d_finished() -> void:
	queue_free()
