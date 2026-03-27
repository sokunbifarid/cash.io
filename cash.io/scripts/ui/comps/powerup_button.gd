extends Button

@onready var powerup_texture_rect: TextureRect = $PowerupPanelTextureRect/PowerupTextureRect
@onready var coin_boost_h_box_container: HBoxContainer = $PowerupPanelTextureRect/CoinBoostHBoxContainer
@onready var powerup_count_label: Label = $PowerupCountLabel

const BOOST_UI = preload("uid://bnfs5vcyxrokp")
const SHIELD_UI = preload("uid://crbo16c1nu43q")
var number_of_current_available_powerup: int = 0
var powerup_id: String = ""

func _ready() -> void:
	SignalManager.player_used_powerup_signal.connect(_on_player_used_powerup_signal)
	SignalManager.powerup_timeout_signal.connect(_on_powerup_timeout_signal)
	enable_button()

func _on_powerup_timeout_signal(id: String) -> void:
	if id == powerup_id:
		enable_button()

func _on_player_used_powerup_signal(payload: Dictionary) -> void:
	if powerup_id == payload.id:
		set_powerup_properties(payload.id, payload.name, payload.quantity)
		disable_button()

func enable_button() -> void:
	self.disabled = false
	self.modulate = Color.WHITE

func disable_button() -> void:
	self.disabled = true
	self.modulate = Color.DARK_GRAY
#"powerups": [{ "id": "8d6bb1c8-3f7f-4c8c-9ef8-6c5a4f0c1b72", "name": "Turbo Booster", "quantity": 20.0 }, { "id": "2f8a9f3d-0f4c-4b9f-8d1d-2f6a7c1e5b13", "name": "Guardian Shield", "quantity": 11.0 }, { "id": "7b14d3c2-6e5a-4c11-9c7e-3d8f2a6b4e90", "name": "Flash Speed", "quantity": 5.0 }], "remaining_sec": 90.0 } }

func set_powerup_properties(id: String, powerup_name: String = "", powerup_quantity: int = 0) -> void:
	powerup_count_label.text = "x" + str(int(powerup_quantity))
	number_of_current_available_powerup = powerup_quantity
	powerup_id = id
	if id == PowerupsManager.GUARDIAN_SHIELD_ID:
		powerup_texture_rect.show()
		coin_boost_h_box_container.hide()
		powerup_texture_rect.texture = SHIELD_UI
	elif id == PowerupsManager.FLASH_SPEED_ID:
		powerup_texture_rect.show()
		coin_boost_h_box_container.hide()
		powerup_texture_rect.texture = BOOST_UI
	elif id == PowerupsManager.TURBO_BOOSTER_ID:
		powerup_texture_rect.hide()
		coin_boost_h_box_container.show()

func _on_pressed() -> void:
	if number_of_current_available_powerup > 0:
		SfxAudioManager.play_button_pressed_sfx()
		GameHttpNetworkManager.send_use_powerup(powerup_id)
		print("send use power button pressed")
