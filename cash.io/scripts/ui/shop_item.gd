extends Button

signal shop_item_pressed(id: String, the_name: String, the_cost: int)


const SHOP_CURRENCY_PURCHASE_PANEL = preload("uid://b0lf5tgclflx0")
const SHOP_SKINS_PURCHASE_PANEL = preload("uid://vnb3rj7in32d")

const BOOST_POWERUP_UI = preload("uid://bnfs5vcyxrokp")
const SHIELD_POWERUP_UI = preload("uid://crbo16c1nu43q")

@onready var shop_item_cost_label: Label = $ShopItemTexture/CostDataHBoxContainer/ShopItemCostLabel
@onready var shop_item_display: TextureRect = $ShopItemTexture/ShopItemDisplay
@onready var coin_boost_h_box_container: HBoxContainer = $ShopItemTexture/CoinBoostHBoxContainer
@onready var shop_item_name_label: Label = $ShopItemTexture/ShopItemNameLabel


var item_id: String = ""
var item_name: String = ""
var item_cost: int = 0

func set_item_data(id: String, the_name: String, cost: int = 0) -> void:
	if id == PowerupsManager.FLASH_SPEED_ID:
		shop_item_display.show()
		shop_item_display.texture = BOOST_POWERUP_UI
		coin_boost_h_box_container.hide()
	elif id == PowerupsManager.GUARDIAN_SHIELD_ID:
		shop_item_display.show()
		shop_item_display.texture = SHIELD_POWERUP_UI
		coin_boost_h_box_container.hide()
	elif id == PowerupsManager.TURBO_BOOSTER_ID:
		shop_item_display.hide()
		coin_boost_h_box_container.show()
	shop_item_cost_label.text = str(cost)
	shop_item_name_label.text = the_name.split(" ")[0]
	item_id = id
	item_name = the_name
	item_cost = cost
	#shop_item_type = item_type
	#if shop_item_type == ALL_SHOP_ITEM_TYPE.COIN:
		#self.texture = SHOP_CURRENCY_PURCHASE_PANEL
	#elif shop_item_type == ALL_SHOP_ITEM_TYPE.SKIN:
		#self.texture = SHOP_SKINS_PURCHASE_PANEL


func _on_pressed() -> void:
	SfxAudioManager.play_button_pressed_sfx()
	shop_item_pressed.emit(item_id, item_name, item_cost)
