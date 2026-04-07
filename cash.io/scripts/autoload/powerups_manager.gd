extends Node


const GUARDIAN_SHIELD_ID: String = "d757e55c-75af-46ac-b541-91965f85692a"
const TURBO_BOOSTER_ID: String = "f96b5944-0896-4041-83d3-e51a5da18ff8"
const FLASH_SPEED_ID: String = "fe0e96ee-eb73-4666-9f88-b178e3440955"

const POWERUPS_DELAY: float = 3.0
const SHIELD_POWERUP_DELAY: float = 5.0
var speed_powerups_delay_timer: Timer = Timer.new()
var boost_powerups_delay_timer: Timer = Timer.new()
var shield_powerups_delay_timer: Timer = Timer.new()


func _ready() -> void:
	randomize()
	connect_signal()
	configure_timers()

func connect_signal() -> void:
	SignalManager.player_used_powerup_signal.connect(_on_player_used_powerup_signal)

func configure_timers() -> void:
	speed_powerups_delay_timer.wait_time = POWERUPS_DELAY
	speed_powerups_delay_timer.autostart = false
	speed_powerups_delay_timer.one_shot = true
	speed_powerups_delay_timer.timeout.connect(_on_speed_powerups_delay_timer)
	boost_powerups_delay_timer.wait_time = POWERUPS_DELAY
	boost_powerups_delay_timer.autostart = false
	boost_powerups_delay_timer.one_shot = true
	boost_powerups_delay_timer.timeout.connect(_on_boost_powerups_delay_timer)
	shield_powerups_delay_timer.wait_time = SHIELD_POWERUP_DELAY
	shield_powerups_delay_timer.autostart = false
	shield_powerups_delay_timer.one_shot = true
	shield_powerups_delay_timer.timeout.connect(_on_shield_powerups_delay_timer)
	call_deferred("add_child", speed_powerups_delay_timer)
	call_deferred("add_child", boost_powerups_delay_timer)
	call_deferred("add_child", shield_powerups_delay_timer)

func force_use_shield() -> void:
	var players: Dictionary = GameHttpNetworkManager.current_player_list
	if players.has(GameHttpNetworkManager.get_current_player_id()):
		players[GameHttpNetworkManager.get_current_player_id()].enable_shield()
		shield_powerups_delay_timer.start()
		print("forced use shield enabled")

func _on_player_used_powerup_signal(payload: Dictionary) -> void:
	var players: Dictionary = GameHttpNetworkManager.current_player_list
	print("powerup door, knocker: ", payload)
	if payload.id == GUARDIAN_SHIELD_ID:
		print("guardian is true")
	else:
		print("guardian is false")
	if payload.id == GUARDIAN_SHIELD_ID:
		print("shield to be active")
		if players.has(GameHttpNetworkManager.get_current_player_id()):
			players[GameHttpNetworkManager.get_current_player_id()].enable_shield()
			shield_powerups_delay_timer.start()
			print("shield  supper active")
	elif payload.id == TURBO_BOOSTER_ID:
		boost_powerups_delay_timer.start()
		for i: String in players:
			if players.has(i):
				if i != GameHttpNetworkManager.get_current_player_id():
					players[i].enable_coin_bonus()
	elif payload.id == FLASH_SPEED_ID:
		speed_powerups_delay_timer.start()
		if players.has(GameHttpNetworkManager.get_current_player_id()):
			players[GameHttpNetworkManager.get_current_player_id()].enable_high_speed()

func _on_speed_powerups_delay_timer() -> void:
	print("speed done")
	SignalManager.emit_powerup_timeout_signal(FLASH_SPEED_ID)
	var players: Dictionary = GameHttpNetworkManager.current_player_list
	if players.has(GameHttpNetworkManager.get_current_player_id()):
		players[GameHttpNetworkManager.get_current_player_id()].disable_shield()

func _on_boost_powerups_delay_timer() -> void:
	print("boost done")
	SignalManager.emit_powerup_timeout_signal(TURBO_BOOSTER_ID)
	var players: Dictionary = GameHttpNetworkManager.current_player_list
	for i: String in players:
		if i != GameHttpNetworkManager.get_current_player_id():
			players[i].disable_coin_bonus()

func _on_shield_powerups_delay_timer() -> void:
	print("shield done")
	SignalManager.emit_powerup_timeout_signal(GUARDIAN_SHIELD_ID)
	var players: Dictionary = GameHttpNetworkManager.current_player_list
	if players.has(GameHttpNetworkManager.get_current_player_id()):
		players[GameHttpNetworkManager.get_current_player_id()].disable_shield()
