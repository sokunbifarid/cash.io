extends Node

signal open_loading_screen(condition: bool)
signal notice(value: String)
signal signin_successful
signal signout_successful
signal prepare_game

signal startup_request_data_loaded_successfully

signal player_data_loaded_successfully_signal(value: Dictionary)
signal  all_rooms_loaded_signal(value: Dictionary)

signal nakama_auth_user_with_google_worked_signal(condition: bool)
signal player_connected_to_multiplayer_network_signal(session_id: String)
signal websocket_disconnected
signal websocket_reconnected

signal error_getting_user_data_signal

signal load_pellets_on_join_match_signal(values: Array)
signal load_players_on_join_match_signal(value: Array)
#signal load_virus_on_join_match_signal(values: Array)

#signal deposit_request_successful_signal
#signal deposit_request_failed_signal

signal withdrawal_form_prompt_signal
signal withdrawal_data_prompt_signal
signal withdrawal_successful_signal

signal wallet_updated_successfull_signal(amount: int)
signal wallet_settlement_failed_signal(status: String)

signal cashout_rejected_signal(duration: float)

signal match_over_signal(value: Dictionary, status: bool)

signal nakama_left_room_successfully_signal

signal reset_game_signal

signal websocket_connection_is_poor_signal(condition: bool)

func emit_open_loading_screen_signal(value: bool) -> void:
	open_loading_screen.emit(value)

func emit_notice_signal(value: String) -> void:
	notice.emit(value)

func emit_signin_successful_signal() -> void:
	signin_successful.emit()

func emit_signout_successful_signal() -> void:
	signout_successful.emit()

func emit_player_data_loaded_successfully_signal(value: Dictionary) -> void:
	player_data_loaded_successfully_signal.emit(value)

func emit_all_rooms_loaded_signal(value: Dictionary) -> void:
	all_rooms_loaded_signal.emit(value)

func emit_prepare_game_signal() -> void:
	prepare_game.emit()

#func emit_deposit_request_successful_signal() -> void:
	#deposit_request_successful_signal.emit()
#
#func emit_deposit_request_failed_signal() -> void:
	#deposit_request_failed_signal.emit()

func emit_withdrawal_form_prompt_signal() -> void:
	withdrawal_form_prompt_signal.emit()

func emit_withdrawal_data_prompt_signal() -> void:
	withdrawal_data_prompt_signal.emit()


func emit_startup_request_data_loaded_successfully() -> void:
	startup_request_data_loaded_successfully.emit()

func emit_nakama_auth_user_with_google_worked_signal(condition: bool) -> void:
	nakama_auth_user_with_google_worked_signal.emit(condition)

func emit_player_connected_to_multiplayer_network_signal(session_id: String) -> void:
	player_connected_to_multiplayer_network_signal.emit(session_id)

func emit_websocket_disconnected_signal() -> void:
	websocket_disconnected.emit()

func emit_websocket_reconnected_signal() -> void:
	websocket_reconnected.emit()

func emit_load_pellets_on_join_match_signal(value: Array) -> void:
	load_pellets_on_join_match_signal.emit(value)

func emit_load_players_on_join_match_signal(value: Array) -> void:
	load_players_on_join_match_signal.emit(value)

#func emit_load_virus_on_join_match_signal(value: Array) -> void:
	#load_virus_on_join_match_signal.emit(value)

func emit_match_over_signal(value: Dictionary, status: bool) -> void:
	match_over_signal.emit(value, status)

func emit_nakama_left_room_successfully_signal() -> void:
	nakama_left_room_successfully_signal.emit()

func emit_reset_game_signal() -> void:
	reset_game_signal.emit()

func emit_error_getting_user_data_signal() -> void:
	error_getting_user_data_signal.emit()

func emit_wallet_updated_successfull_signal(value: int) -> void:
	wallet_updated_successfull_signal.emit(value)

func emit_wallet_settlement_failed_signal(status: String) -> void:
	wallet_settlement_failed_signal.emit(status)

func emit_cashout_rejected_signal(duration: float) -> void:
	cashout_rejected_signal.emit(duration)

func emit_withdrawal_successful_signal() -> void:
	withdrawal_successful_signal.emit()

func emit_websocket_connection_is_poor_signal(condition: bool) -> void:
	websocket_connection_is_poor_signal.emit(condition)
