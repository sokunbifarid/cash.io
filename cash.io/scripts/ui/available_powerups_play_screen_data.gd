extends VBoxContainer

@onready var powerup_texture_rect: TextureRect = $PowerupTextureRect
@onready var powerup_quantity_label: Label = $PowerupQuantityLabel
@onready var coin_boost_h_box_container: HBoxContainer = $CoinBoostHBoxContainer

const BOOST_UI = preload("uid://bnfs5vcyxrokp")
const SHIELD_UI = preload("uid://crbo16c1nu43q")

func set_data(id: String, powerup_quantity: int) -> void:
	powerup_quantity_label.text = "x" + str(powerup_quantity)
	match id:
		PowerupsManager.FLASH_SPEED_ID:
			powerup_texture_rect.texture = BOOST_UI
			coin_boost_h_box_container.hide()
			powerup_texture_rect.show()
			#self.add_theme_constant_override("separation", -10)
		PowerupsManager.TURBO_BOOSTER_ID:
			coin_boost_h_box_container.show()
			powerup_texture_rect.hide()
			#self.add_theme_constant_override("separation", -5)
		PowerupsManager.GUARDIAN_SHIELD_ID:
			powerup_texture_rect.texture = SHIELD_UI
			coin_boost_h_box_container.hide()
			powerup_texture_rect.show()
			#self.add_theme_constant_override("separation", -10)
