extends Panel

signal close_shop

@onready var shop_panel: Panel = $ShopPanel
@onready var coins_skins_button_textured: TextureButton = $ShopPanel/VBoxContainer/CoinsSkinsButtonTextured
@onready var coins_items_v_box_container: VBoxContainer = $ShopPanel/VBoxContainer/ShopItemCategory/CoinsItemsVBoxContainer
@onready var skins_items_v_box_container: VBoxContainer = $ShopPanel/VBoxContainer/ShopItemCategory/SkinsItemsVBoxContainer
@onready var coins_items_grid_container: GridContainer = $ShopPanel/VBoxContainer/ShopItemCategory/CoinsItemsVBoxContainer/ScrollContainer/CoinsItemsGridContainer
@onready var skins_items_grid_container: GridContainer = $ShopPanel/VBoxContainer/ShopItemCategory/SkinsItemsVBoxContainer/ScrollContainer/SkinsItemsGridContainer

const SHOP_ITEM = preload("uid://dbed714aqjing")

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

enum all_shop_category{COIN, SKIN}
var active_shop_category: all_shop_category = all_shop_category.COIN
var shop_data: Dictionary = {
	"coin": {},
	"skin": {}
}



func _ready() -> void:
	set_visible_shop_category_on_load()
	populate_shop()
	self.hide()

func open_shop() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.SHOP
	self.show()
	shop_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(shop_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func set_visible_shop_category_on_load()-> void:
	if coins_skins_button_textured.button_pressed:
		active_shop_category = all_shop_category.SKIN
	else:
		active_shop_category = all_shop_category.COIN
	set_visible_shop_category()

func set_visible_shop_category() -> void:
	match active_shop_category:
		all_shop_category.COIN:
			coins_items_v_box_container.show()
			skins_items_v_box_container.hide()
		all_shop_category.SKIN:
			skins_items_v_box_container.show()
			coins_items_v_box_container.hide()

func populate_shop() -> void:
	for i: String in shop_data:
		if i == "coin":
			for j:String in shop_data[i]:
				var item: TextureRect = SHOP_ITEM.instantiate()
				coins_items_grid_container.add_child(item)
				if shop_data[i][j].has("coin") and shop_data[i][j].has("texture"):
					item.set_item_data(0, shop_data[i][j]["texture"], shop_data[i][j]["cost"])
		elif i == "skin":
			for j:String in shop_data[i]:
				var item: TextureRect = SHOP_ITEM.instantiate()
				skins_items_grid_container.add_child(item)
				if shop_data[i][j].has("coin") and shop_data[i][j].has("texture"):
					item.set_item_data(1, shop_data[i][j]["texture"], shop_data[i][j]["cost"])

func _on_close_button_textured_pressed() -> void:
	self.hide()
	close_shop.emit()

func _on_coins_skins_button_textured_toggled(toggled_on: bool) -> void:
	if toggled_on:
		active_shop_category = all_shop_category.SKIN
	else:
		active_shop_category = all_shop_category.COIN
	set_visible_shop_category()
