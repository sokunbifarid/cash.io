extends Panel

signal close_shop

@onready var shop_panel: Panel = $ShopPanel
@onready var coins_items_v_box_container: VBoxContainer = $ShopPanel/VBoxContainer/ShopItemCategory/CoinsItemsVBoxContainer
@onready var skins_items_v_box_container: VBoxContainer = $ShopPanel/VBoxContainer/ShopItemCategory/SkinsItemsVBoxContainer
@onready var coins_items_grid_container: GridContainer = $ShopPanel/VBoxContainer/ShopItemCategory/CoinsItemsVBoxContainer/ScrollContainer/CoinsItemsGridContainer
@onready var skins_items_grid_container: GridContainer = $ShopPanel/VBoxContainer/ShopItemCategory/SkinsItemsVBoxContainer/ScrollContainer/SkinsItemsGridContainer
@onready var confirm_shop_purchase_panel: Panel = $ConfirmShopPurchasePanel
@onready var confirm_shop_panel_texture_rect: TextureRect = $ConfirmShopPurchasePanel/ConfirmShopPanelTextureRect
@onready var confirm_purchase_texture_rect: TextureRect = $ConfirmShopPurchasePanel/ConfirmShopPanelTextureRect/ConfirmPurchaseSorterVBoxContainer/ConfirmPurchaseItemsVBoxContainer/ConfirmPurchaseTextureRect
@onready var confirm_purchase_label: Label = $ConfirmShopPurchasePanel/ConfirmShopPanelTextureRect/ConfirmPurchaseSorterVBoxContainer/ConfirmPurchaseItemsVBoxContainer/ConfirmPurchaseLabel
@onready var confirm_purchase_button_text_label: Label = $ConfirmShopPurchasePanel/ConfirmShopPanelTextureRect/ConfirmPurchaseSorterVBoxContainer/ButtonsSorterHBoxContainer/ConfirmPurchasePurchaseButtonTextured_1/ButtonTextureRect/ButtonSorterHBoxContainer/ButtonTextLabel
@onready var purchase_successful_panel: Panel = $PurchaseSuccessfulPanel
@onready var powerups_items_grid_container: GridContainer = $ShopPanel/VBoxContainer/ShopItemCategory/PowerupsItemsVBoxContainer/ScrollContainer/PowerupsItemsGridContainer
@onready var powerups_items_v_box_container: VBoxContainer = $ShopPanel/VBoxContainer/ShopItemCategory/PowerupsItemsVBoxContainer
@onready var coin_boost_confirm_purchase_h_box_container: HBoxContainer = $ConfirmShopPurchasePanel/ConfirmShopPanelTextureRect/ConfirmPurchaseSorterVBoxContainer/ConfirmPurchaseItemsVBoxContainer/CoinBoostHBoxContainer
@onready var coins_button_textured: Button = $ShopPanel/VBoxContainer/HBoxContainer/CoinsButtonTextured
@onready var skins_button_textured: Button = $ShopPanel/VBoxContainer/HBoxContainer/SkinsButtonTextured
@onready var powerups_button_textured: Button = $ShopPanel/VBoxContainer/HBoxContainer/PowerupsButtonTextured

const SHOP_ITEM = preload("uid://dbed714aqjing")
const SHOP_CATEGORY_SELECTED = preload("uid://c2s51oi2wcmwl")
const SHOP_CATEGORY_UNSELECTED = preload("uid://cibh8lyoe0srb")

const BOOST_POWERUP_UI = preload("uid://bnfs5vcyxrokp")
const SHIELD_POWERUP_UI = preload("uid://crbo16c1nu43q")

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

enum all_shop_category{COIN, SKIN, POWERUPS}
var active_shop_category: all_shop_category = all_shop_category.POWERUPS
var shop_data_to_purchase: Dictionary = {"name": "", "price": 0, "id": ""}

func _ready() -> void:
	set_visible_shop_category_on_load()
	populate_shop()
	connect_signal()
	self.hide()
	close_confirm_shop_purchase()
	close_purchase_successful()

func connect_signal() -> void:
	SignalManager.shop_data_loaded_signal.connect(_on_shop_data_loaded_signal)
	SignalManager.shop_purchase_successful_signal.connect(_on_shop_purchase_successful_signal)

func _on_shop_data_loaded_signal(payload: Dictionary) -> void:
	print("shop data loaded: ", payload)
	populate_shop(payload.items)

func _on_shop_purchase_successful_signal() -> void:
	close_confirm_shop_purchase()
	open_purchase_successful()

func open_shop() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.SHOP
	self.show()
	shop_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(shop_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func open_confirm_shop_purchase() -> void:
	confirm_shop_purchase_panel.show()
	confirm_shop_panel_texture_rect.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(confirm_shop_panel_texture_rect, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func close_confirm_shop_purchase() -> void:
	confirm_shop_purchase_panel.hide()
	shop_data_to_purchase = {"name": "", "price": 0, "id": ""}

func open_purchase_successful() -> void:
	close_confirm_shop_purchase()
	purchase_successful_panel.show()
	purchase_successful_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(purchase_successful_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)
	SfxAudioManager.play_successful_sfx()

func close_purchase_successful() -> void:
	purchase_successful_panel.hide()

func set_visible_shop_category_on_load()-> void:
	set_visible_shop_category()

func clear_all_shop_category_button_selected_highlight() -> void:
	skins_button_textured.get_child(0).texture = SHOP_CATEGORY_UNSELECTED
	coins_button_textured.get_child(0).texture = SHOP_CATEGORY_UNSELECTED
	skins_button_textured.get_child(0).texture = SHOP_CATEGORY_UNSELECTED

func set_visible_shop_category() -> void:
	clear_all_shop_category_button_selected_highlight()
	match active_shop_category:
		all_shop_category.COIN:
			skins_button_textured.get_child(0).texture = SHOP_CATEGORY_SELECTED
			coins_items_v_box_container.show()
			skins_items_v_box_container.hide()
			powerups_items_v_box_container.hide()
		all_shop_category.SKIN:
			coins_button_textured.get_child(0).texture = SHOP_CATEGORY_SELECTED
			skins_items_v_box_container.show()
			coins_items_v_box_container.hide()
			powerups_items_v_box_container.hide()
		all_shop_category.POWERUPS:
			skins_button_textured.get_child(0).texture = SHOP_CATEGORY_SELECTED
			skins_items_v_box_container.hide()
			coins_items_v_box_container.hide()
			powerups_items_v_box_container.show()

func populate_shop(items: Array = []) -> void:
	for i: Dictionary in items:
		var item: Button = SHOP_ITEM.instantiate()
		powerups_items_grid_container.add_child(item)
		item.set_item_data(i.id, i.name, i.price)
		item.shop_item_pressed.connect(_on_shop_item_pressed)

func item_to_purchase(data: Dictionary) -> void:
	print("data: ", data)
	match data.id:
		PowerupsManager.FLASH_SPEED_ID:
			coin_boost_confirm_purchase_h_box_container.hide()
			confirm_purchase_texture_rect.show()
			confirm_purchase_texture_rect.texture = BOOST_POWERUP_UI
		PowerupsManager.GUARDIAN_SHIELD_ID:
			coin_boost_confirm_purchase_h_box_container.hide()
			confirm_purchase_texture_rect.show()
			confirm_purchase_texture_rect.texture = SHIELD_POWERUP_UI
		PowerupsManager.TURBO_BOOSTER_ID:
			coin_boost_confirm_purchase_h_box_container.show()
			confirm_purchase_texture_rect.hide()
	confirm_purchase_label.text = "Buy x1 " + data.name
	confirm_purchase_button_text_label.text = str(data.price)
	open_confirm_shop_purchase()

func _on_shop_item_pressed(the_id: String, the_name: String, the_cost: int) -> void:
	shop_data_to_purchase.name = the_name
	shop_data_to_purchase.price = the_cost
	shop_data_to_purchase.id = the_id
	item_to_purchase(shop_data_to_purchase)

func _on_close_button_textured_pressed() -> void:
	self.hide()
	close_shop.emit()

func _on_confirm_purchase_purchase_button_textured_1_pressed() -> void:
	HttpNetworkManager.request_shop_item_purchase(shop_data_to_purchase.id)


func _on_confirm_purchase_back_button_textured_2_pressed() -> void:
	close_confirm_shop_purchase()


func _on_purchase_successful_back_button_textured_pressed() -> void:
	close_purchase_successful()


func _on_coins_button_textured_pressed() -> void:
	active_shop_category = all_shop_category.COIN
	set_visible_shop_category()


func _on_skins_button_textured_pressed() -> void:
	active_shop_category = all_shop_category.SKIN
	set_visible_shop_category()


func _on_powerups_button_textured_pressed() -> void:
	active_shop_category = all_shop_category.POWERUPS
	set_visible_shop_category()
