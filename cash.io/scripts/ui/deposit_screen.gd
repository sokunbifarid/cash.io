extends Control

signal close_deposit

@onready var deposit_screen_panel: Panel = $DepositScreenPanel
@onready var enter_amount_value_line_edit: LineEdit = $DepositScreenPanel/DepositTextureRect/UIButtonsVBoxContainer/EnterAmountVBoxContainer/EnterAmountValueLineEdit
@onready var payment_successful_screen_panel: Panel = $PaymentSuccessfulScreenPanel
@onready var deposit_method_method_screen_panel: Panel = $DepositMethodMethodScreenPanel


var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25
var waiting_to_confirm_deposit: bool = false

func _ready() -> void:
	SignalManager.wallet_updated_successfull_signal.connect(_on_wallet_updated_successfull_signal)
	SignalManager.wallet_settlement_failed_signal.connect(_on_wallet_settlement_failed_signal)
	hide_all_screens()

func _on_wallet_updated_successfull_signal(_value: int) -> void:
	print("wallet updated: ", self.visible)
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.DEPOSIT:
		print("wallet updated passed here for deposit")
		open_deposit_successful()
		SignalManager.emit_open_loading_screen_signal(false)
		enter_amount_value_line_edit.text = ""

func _on_wallet_settlement_failed_signal(status: String) -> void:
	if self.visible:
		SignalManager.emit_notice_signal("Deposit Couldn't be processed")
		SignalManager.emit_notice_signal(status)
		SignalManager.emit_open_loading_screen_signal(false)

func hide_all_screens() -> void:
	deposit_method_method_screen_panel.hide()
	deposit_screen_panel.hide()
	payment_successful_screen_panel.hide()
	enter_amount_value_line_edit.text = ""

func open_deposit() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.DEPOSIT
	self.show()
	hide_all_screens()
	deposit_method_method_screen_panel.show()
	deposit_method_method_screen_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(deposit_method_method_screen_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)


func open_deposit_screen() -> void:
	self.show()
	hide_all_screens()
	enter_amount_value_line_edit.text = ""
	deposit_screen_panel.show()
	deposit_screen_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(deposit_screen_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func open_deposit_successful() -> void:
	payment_successful_screen_panel.show()
	payment_successful_screen_panel.get_child(0).scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(payment_successful_screen_panel.get_child(0), "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func _on_deposit_back_button_textured_pressed() -> void:
	hide_all_screens()
	open_deposit()

func _on_payment_successful_back_button_textured_pressed() -> void:
	hide_all_screens()
	open_deposit()

func _on_crypto_deposit_method_button_textured_pressed() -> void:
	hide_all_screens()
	open_deposit_screen()
	HttpNetworkManager.set_current_payment_provider_to_coinremitter()


func _on_naira_deposit_method_button_textured_pressed() -> void:
	hide_all_screens()
	open_deposit_screen()
	HttpNetworkManager.set_current_payment_provider_to_opay()


func _on_deposit_submission_button_textured_pressed() -> void:
	HttpNetworkManager.set_current_payment_amount(int(enter_amount_value_line_edit.text))
	HttpNetworkManager.request_http_deposit()
	SignalManager.emit_open_loading_screen_signal(true)


func _on_deposit_method_back_button_textured_pressed() -> void:
	close_deposit.emit()
