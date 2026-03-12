extends Control

@onready var main_menu_screen: Control = $MainMenuScreen
@onready var play_screen: Control = $PlayScreen
@onready var settings_screen: Control = $SettingsScreen
@onready var shop_screen: Panel = $ShopScreen
@onready var profile_screen: Control = $ProfileScreen
@onready var deposit_screen: Control = $DepositScreen
@onready var withdrawal_screen: Control = $WithdrawalScreen
@onready var player_settled_screen: Control = $PlayerSettledScreen


var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_all_screen()
	main_menu_screen.show()
	main_menu_screen.scale = Vector2(1,1)
	SignalManager.signout_successful.connect(_on_signout_successful)

func _on_signout_successful() -> void:
	hide_all_screen()
	main_menu_screen.show()
	main_menu_screen.scale = Vector2(1,1)

func hide_all_screen() -> void:
	main_menu_screen.hide()
	play_screen.hide()
	settings_screen.hide()
	shop_screen.hide()
	profile_screen.hide()
	deposit_screen.hide()
	withdrawal_screen.hide()
	player_settled_screen.hide()

func open_menu() -> void:
	hide_all_screen()
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.MAINMENU
	self.show()
	main_menu_screen.show()
	main_menu_screen.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(main_menu_screen, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)


func _on_settings_button_textured_pressed() -> void:
	hide_all_screen()
	settings_screen.open_settings()

func check_room_condition(cost: int) -> bool:
	if GlobalManager.get_player_coin_amount() >= cost:
		return true
	else:
		SignalManager.emit_notice_signal("Insufficent Coin Balance")
		return false

func load_game() -> void:
	SignalManager.emit_open_loading_screen_signal(true)
	SignalManager.emit_prepare_game_signal()
	await get_tree().create_timer(2.0).timeout
	SignalManager.emit_open_game_signal()

func _on_bubbles_mode_button_textured_pressed() -> void:
	hide_all_screen()
	play_screen.open_play_screen()


func _on_lines_game_mode_button_textured_pressed() -> void:
	pass # Replace with function body.

func _on_settings_screen_close_settings() -> void:
	hide_all_screen()
	open_menu()

func _on_shop_button_textured_pressed() -> void:
	hide_all_screen()
	shop_screen.open_shop()

func _on_shop_screen_close_shop() -> void:
	hide_all_screen()
	open_menu()

func _on_profile_button_textured_pressed() -> void:
	hide_all_screen()
	profile_screen.open_profile()

func _on_profile_screen_close_profile() -> void:
	hide_all_screen()
	open_menu()


func _on_play_screen_play_screen_closed() -> void:
	hide_all_screen()
	open_menu()

func _on_buy_coin_details_buy_coin_button() -> void:
	hide_all_screen()
	deposit_screen.open_deposit()

func _on_deposit_screen_close_deposit() -> void:
	hide_all_screen()
	open_menu()


func _on_withdrawal_screen_close_withdrawal_screen() -> void:
	hide_all_screen()
	settings_screen.open_settings()

func _on_settings_screen_open_withdrawal() -> void:
	hide_all_screen()
	withdrawal_screen.open_withdrawal()
