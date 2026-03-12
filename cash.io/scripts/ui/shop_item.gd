extends TextureRect

@export var shop_item_type: ALL_SHOP_ITEM_TYPE = ALL_SHOP_ITEM_TYPE.COIN

const SHOP_CURRENCY_PURCHASE_PANEL = preload("uid://blv14l2gw17oj")
const SHOP_SKIN_PURCHASE_PANEL = preload("uid://cj5acpsjga04s")

enum ALL_SHOP_ITEM_TYPE{COIN, SKIN}

@onready var shop_item_display: TextureRect = $ShopItemDisplay
@onready var shop_item_cost_label: Label = $ShopItemCostLabel


func set_item_data(item_type: int = 0, item_texture: String = "", cost: int = 0) -> void:
	shop_item_display.texture = ResourceLoader.load(item_texture)
	shop_item_cost_label.text = str(cost)
	shop_item_type = item_type
	if shop_item_type == ALL_SHOP_ITEM_TYPE.COIN:
		self.texture = SHOP_CURRENCY_PURCHASE_PANEL
	elif shop_item_type == ALL_SHOP_ITEM_TYPE.SKIN:
		self.texture = SHOP_SKIN_PURCHASE_PANEL
