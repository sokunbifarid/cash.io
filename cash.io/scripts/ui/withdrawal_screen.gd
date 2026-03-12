extends Control

signal open_withdrawal_screen
signal close_withdrawal_screen

@onready var withdrawal_form_screen_panel: Panel = $WithdrawalFormScreenPanel
@onready var withdrawal_form_account_name_value_line_edit: LineEdit = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/AccountNameVBoxContainer/WithdrawalFormAccountNameValueLineEdit
@onready var withdrawal_form_account_number_value_line_edit: LineEdit = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/AccountNumberVBoxContainer/WithdrawalFormAccountNumberValueLineEdit
@onready var withdrawal_form_bank_name_value_line_edit: LineEdit = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/BankNameVBoxContainer/WithdrawalFormBankNameValueLineEdit
@onready var withdrawal_form_withdrawal_amount_value_line_edit: LineEdit = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/WithdrawalAmountVBoxContainer/WithdrawalFormWithdrawalAmountValueLineEdit
@onready var withdrawal_data_screen_panel: Panel = $WithdrawalDataScreenPanel
@onready var withdrawal_data_withdrawal_amount_value_line_edit: LineEdit = $WithdrawalDataScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/WithdrawalAmountVBoxContainer/WithdrawalDataWithdrawalAmountValueLineEdit
@onready var withdrawal_in_progress_screen_panel: Panel = $WithdrawalInProgressScreenPanel
@onready var withdrawal_method_screen_panel: Panel = $WithdrawalMethodScreenPanel
@onready var account_name_v_box_container: VBoxContainer = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/AccountNameVBoxContainer
@onready var account_number_v_box_container: VBoxContainer = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/AccountNumberVBoxContainer
@onready var bank_name_v_box_container: VBoxContainer = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/BankNameVBoxContainer
@onready var crypto_address_v_box_container: VBoxContainer = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/CryptoAddressVBoxContainer
@onready var withdrawal_amount_v_box_container: VBoxContainer = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/WithdrawalAmountVBoxContainer
@onready var withdrawal_form_crypto_address_value_line_edit: LineEdit = $WithdrawalFormScreenPanel/WithdrawalTextureRect/UIButtonsVBoxContainer/WithdrawalDetailsVBoxContainer/CryptoAddressVBoxContainer/WithdrawalFormCryptoAddressValueLineEdit

var the_visibility_tween: Tween

const TWEEN_DURATION: float = 0.25

var alphabet_regex: RegEx = RegEx.new()
var number_regex: RegEx = RegEx.new()

func _ready() -> void:
	alphabet_regex.compile("[^a-zA-Z ]")
	number_regex.compile("[^0-9]")
	SignalManager.withdrawal_form_prompt_signal.connect(_on_withdrawal_form_prompt_signal)
	SignalManager.withdrawal_data_prompt_signal.connect(_on_withdrawal_data_prompt_signal)
	SignalManager.wallet_updated_successfull_signal.connect(_on_wallet_updated_successfull_signal)
	SignalManager.wallet_settlement_failed_signal.connect(_on_wallet_settlement_failed_signal)
	#SignalManager.withdrawal_successful_signal.connect(_on_withdrawal_successful_signal)
	self.hide()
	hide_all_screen()

func hide_all_screen() -> void:
	withdrawal_form_screen_panel.hide()
	withdrawal_data_screen_panel.hide()
	withdrawal_in_progress_screen_panel.hide()
	withdrawal_method_screen_panel.hide()
	clear_all_text_fields()

func _on_withdrawal_form_prompt_signal() -> void:
	#open_withdrawal_screen.emit()
	self.show()
	open_withdrawal_form()

func _on_withdrawal_data_prompt_signal() -> void:
	#open_withdrawal_screen.emit()
	self.show()
	open_withdrawal_data()

func _on_wallet_updated_successfull_signal(_value: int) -> void:
	print("wallet updated successfully")
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.WITHDRAWAL:
		open_withdrawal_in_progress()
		SignalManager.emit_open_loading_screen_signal(false)

func _on_wallet_settlement_failed_signal(status: String) -> void:
	if GlobalManager.current_game_state == GlobalManager.GAME_STATE.WITHDRAWAL:
		SignalManager.emit_notice_signal("Withdrawal couldn't be processed, try again")
		SignalManager.emit_notice_signal(status)
		SignalManager.emit_open_loading_screen_signal(false)

#func _on_withdrawal_successful_signal() -> void:
	#if self.visible:
		#open_withdrawal_in_progress()
		#SignalManager.emit_open_loading_screen_signal(false)

func open_withdrawal() -> void:
	GlobalManager.current_game_state = GlobalManager.GAME_STATE.WITHDRAWAL
	self.show()
	hide_all_screen()
	withdrawal_method_screen_panel.show()
	withdrawal_method_screen_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(withdrawal_method_screen_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func open_withdrawal_form() ->  void:
	hide_all_screen()
	set_visible_ui_based_on_payment_provider()
	withdrawal_form_screen_panel.show()
	withdrawal_form_screen_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(withdrawal_form_screen_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func open_withdrawal_data() -> void:
	hide_all_screen()
	withdrawal_data_screen_panel.show()
	withdrawal_data_screen_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(withdrawal_data_screen_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func open_withdrawal_in_progress() -> void:
	withdrawal_in_progress_screen_panel.show()
	withdrawal_in_progress_screen_panel.scale = Vector2.ZERO
	if the_visibility_tween:
		the_visibility_tween.kill()
	the_visibility_tween = create_tween()
	the_visibility_tween.tween_property(withdrawal_in_progress_screen_panel, "scale", Vector2(1,1), TWEEN_DURATION).set_trans(Tween.TRANS_ELASTIC)

func clear_all_text_fields() -> void:
	withdrawal_form_bank_name_value_line_edit.text = ""
	withdrawal_form_account_name_value_line_edit.text = ""
	withdrawal_form_account_number_value_line_edit.text = ""
	withdrawal_form_crypto_address_value_line_edit.text = ""
	withdrawal_data_withdrawal_amount_value_line_edit.text = ""
	withdrawal_form_withdrawal_amount_value_line_edit.text = ""

func set_visible_ui_based_on_payment_provider() -> void:
	if HttpNetworkManager.check_if_payment_provider_is_opay():
		account_name_v_box_container.show()
		account_number_v_box_container.show()
		bank_name_v_box_container.show()
		crypto_address_v_box_container.hide()
	elif HttpNetworkManager.check_if_payment_provider_is_coinremitter():
		crypto_address_v_box_container.show()
		account_name_v_box_container.hide()
		account_number_v_box_container.hide()
		bank_name_v_box_container.hide()
	withdrawal_amount_v_box_container.show()

func _on_withdrawal_form_submit_button_textured_pressed() -> void:
	if withdrawal_form_account_name_value_line_edit.text == "" or withdrawal_form_account_number_value_line_edit.text == "" or withdrawal_form_bank_name_value_line_edit.text == "" or withdrawal_form_withdrawal_amount_value_line_edit.text == "":
		SignalManager.emit_notice_signal("Ensure all data slots are filled")
	else:
		var data: Dictionary =  {}
		if HttpNetworkManager.check_if_payment_provider_is_opay():
			data =  {
				"amount_minor": int(withdrawal_form_withdrawal_amount_value_line_edit.text),
				"provider": HttpNetworkManager.get_current_payment_provider(),
				"bank_details": {
					"account_name": withdrawal_form_account_name_value_line_edit.text,
					"account_number": withdrawal_form_account_number_value_line_edit.text,
					"bank_name": withdrawal_form_bank_name_value_line_edit.text
				}
			}
			print("opay withdrawal form payload: ", data)
		elif HttpNetworkManager.check_if_payment_provider_is_coinremitter():
			data =   {
				"amount_minor": int(withdrawal_form_withdrawal_amount_value_line_edit.text),
				"provider": HttpNetworkManager.get_current_payment_provider(),
				"crypto_address": withdrawal_form_crypto_address_value_line_edit.text
				}
			print("crypto withdrawal form payload: ", data)
		HttpNetworkManager.request_http_withdrawal(data)

func _on_withdrawal_data_submit_button_textured_pressed() -> void:
	if withdrawal_data_withdrawal_amount_value_line_edit.text == "":
		SignalManager.emit_notice_signal("Amount to withdraw cannot be empty")
	else:
		var data: Dictionary = {
			"amount_minor": int(withdrawal_data_withdrawal_amount_value_line_edit.text),
			"provider": HttpNetworkManager.get_current_payment_provider()
			}
		HttpNetworkManager.request_http_withdrawal(data)

func _on_withdrawal_form_account_name_value_line_edit_text_changed(new_text: String) -> void:
	var old_caret_position: int = withdrawal_form_account_name_value_line_edit.caret_column
	var filtered_text = alphabet_regex.sub(new_text, "", true)
	while "  " in filtered_text:
		filtered_text = filtered_text.replace("  ", " ")
	if new_text != filtered_text:
		withdrawal_form_account_name_value_line_edit.text = filtered_text
		withdrawal_form_account_name_value_line_edit.caret_column = old_caret_position - 1

func _on_withdrawal_form_account_number_value_line_edit_text_changed(new_text: String) -> void:
	var old_caret_position: int = withdrawal_form_account_number_value_line_edit.caret_column
	var filtered_text = number_regex.sub(new_text, "", true)
	while "  " in filtered_text:
		filtered_text = filtered_text.replace("  ", " ")
	if new_text != filtered_text:
		withdrawal_form_account_number_value_line_edit.text = filtered_text
		withdrawal_form_account_number_value_line_edit.caret_column = old_caret_position - 1

func _on_withdrawal_form_bank_name_value_line_edit_text_changed(new_text: String) -> void:
	var old_caret_position: int = withdrawal_form_bank_name_value_line_edit.caret_column
	var filtered_text = alphabet_regex.sub(new_text, "", true)
	while "  " in filtered_text:
		filtered_text = filtered_text.replace("  ", " ")
	if new_text != filtered_text:
		withdrawal_form_bank_name_value_line_edit.text = filtered_text
		withdrawal_form_bank_name_value_line_edit.caret_column = old_caret_position - 1

func _on_withdrawal_form_withdrawal_amount_value_line_edit_text_changed(new_text: String) -> void:
	var old_caret_position: int = withdrawal_form_withdrawal_amount_value_line_edit.caret_column
	var filtered_text = number_regex.sub(new_text, "", true)
	if new_text != filtered_text:
		withdrawal_form_withdrawal_amount_value_line_edit.text = filtered_text
		withdrawal_form_withdrawal_amount_value_line_edit.caret_column = old_caret_position - 1

func _on_withdrawal_data_withdrawal_amount_value_line_edit_text_changed(new_text: String) -> void:
	var old_caret_position: int = withdrawal_data_withdrawal_amount_value_line_edit.caret_column
	var filtered_text = number_regex.sub(new_text, "", true)
	if new_text != filtered_text:
		withdrawal_data_withdrawal_amount_value_line_edit.text = filtered_text
		withdrawal_data_withdrawal_amount_value_line_edit.caret_column = old_caret_position - 1


func _on_withdrawal_data_back_button_textured_pressed() -> void:
	hide_all_screen()
	open_withdrawal()


func _on_withdrawal_form_back_button_textured_pressed() -> void:
	close_withdrawal_screen.emit()
	self.hide()


func _on_withdrawal_in_progress_back_button_textured_pressed() -> void:
	withdrawal_in_progress_screen_panel.hide()


func _on_naira_withdrawal_method_button_textured_pressed() -> void:
	HttpNetworkManager.request_http_check_withdrawal()
	HttpNetworkManager.set_current_payment_provider_to_opay()


func _on_crypto_withdrawal_method_button_textured_pressed() -> void:
	HttpNetworkManager.request_http_check_withdrawal()
	HttpNetworkManager.set_current_payment_provider_to_coinremitter()

func _on_withdrawal_method_back_button_textured_pressed() -> void:
	close_withdrawal_screen.emit()
	self.hide()

func _on_withdrawal_form_crypto_address_value_line_edit_text_changed(new_text: String) -> void:
	var old_caret_position: int = withdrawal_form_crypto_address_value_line_edit.caret_column
	if new_text.contains(" "):
		new_text = new_text.replace(" ", "")
	elif new_text.contains("  "):
		new_text = new_text.replace("  ", "")
	withdrawal_form_crypto_address_value_line_edit.text = new_text
	withdrawal_form_crypto_address_value_line_edit.caret_column = old_caret_position - 1
