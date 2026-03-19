extends Node

@export var character_holder: Node2D
@export var pellets_holder: Node2D
@export var viruses_holder: Node2D
@export var game_map: Sprite2D

const CHARACTER = preload("uid://bnntymquehaja")
const PELLETS = preload("uid://v2js4x2t6odi")

const PELLETS_POSSIBLE_COLORS: Array = [Color(0.922, 0.349, 0.349),Color(0.35, 0.483, 0.92),]

func _ready() -> void:
	randomize()
	connect_signal()


func connect_signal() -> void:
	#SignalManager.player_connected_to_multiplayer_network_signal.connect(_on_player_connected_to_multiplayer_network_signal)
	SignalManager.load_players_on_join_match_signal.connect(_on_load_players_on_join_match_signal)
	SignalManager.load_pellets_on_join_match_signal.connect(_on_load_pellets_on_join_match_signal)
	SignalManager.prepare_game_for_play_again_signal.connect(_on_prepare_game_for_play_again_signal)
	#SignalManager.load_virus_on_join_match_signal.connect(_on_load_virus_on_join_match_signal)
	SignalManager.reset_game_signal.connect(_on_reset_game_signal)
	SignalManager.match_over_signal.connect(_on_match_over_signal)


func _on_prepare_game_for_play_again_signal() -> void:
	remove_all_old_pellets()
	remove_all_old_players()

#func _on_player_connected_to_multiplayer_network_signal(session_id: String) -> void:
	#spawn_networked_player(session_id)

func _on_load_pellets_on_join_match_signal(pellets: Array) -> void:
	spawn_networked_pellets(pellets)


func _on_load_players_on_join_match_signal(players: Array, bound: Vector2) -> void:
	print("load players on join match signal fired")
	spawn_networked_player(players, bound)
	print("on load bounds: ", bound)
	set_process(true)
	set_bounds(bound)

#func _on_load_virus_on_join_match_signal(viruses: Array) -> void:
	#spawn_networked_virus(viruses)

func _on_match_over_signal(_payload: Dictionary, condition: bool) -> void:
	set_process(false)

func _process(delta: float) -> void:
	if GameHttpNetworkManager.room_bound != Vector2.ZERO:
		set_bounds(GameHttpNetworkManager.room_bound)
		print("mapper bounds: ", GameHttpNetworkManager.room_bound)

func set_bounds(bounds: Vector2) -> void:
	if game_map:
		const LIMIT_OFFSET: float = 50
		if bounds != Vector2.ZERO:
			bounds = bounds - Vector2(LIMIT_OFFSET, LIMIT_OFFSET)
			game_map.region_rect = Rect2(0,0, bounds.x, bounds.y)
			game_map.position = Vector2(LIMIT_OFFSET, LIMIT_OFFSET)


#use this when a game ends
func remove_all_old_players() -> void:
	for i in character_holder.get_children():
		i.queue_free()

func remove_all_old_pellets() -> void:
	for i in pellets_holder.get_children():
		i.queue_free()

func spawn_networked_player(players: Array, bound: Vector2) -> void:
	if character_holder:
		for i: Dictionary in players:
			var new_player: Node2D = CHARACTER.instantiate()
			var id: String = ""
			var new_position: Vector2 = Vector2.ZERO
			var character_name: String = ""
			var coins: int = 0
			var mass: float = 0
			var appearance: String = ""
			if i.has("x") and i.has("y"):
				new_position = Vector2(i.x, i.y)
			if i.has("id"):
				id = i.id
			if i.has("coins"):
				coins = i.coins
			if i.has("mass"):
				mass = i.mass/5
			if i.has("appearance"):
				appearance = i.appearance
			if i.has("username"):
				character_name = i.username
				print("character name: ", character_name)
			print("player id: ", id)
			print("master player id: ", id)
			character_holder.add_child(new_player)
			new_player.set_force_data(new_position, mass, coins, appearance, character_name)
			new_player.name = character_name
			new_player.show()
			print("player is spawned")
			if GameHttpNetworkManager.get_current_player_id() == id:
				print("this player is the authority")
				new_player.character_enabled(true, bound)
			else:
				print("this player is not authority")
				new_player.character_enabled(false, bound)
			GameHttpNetworkManager.update_players_list(id, new_player)
	else:
		print("character holder not set in game IngameNetworkManager")

func spawn_networked_pellets( pellets: Array) -> void:
	if pellets_holder:
		for i: Dictionary in pellets:
			var pellet: Sprite2D = PELLETS.instantiate()
			var pellet_name: String = ""
			var pellet_scale: Vector2 = Vector2.ZERO
			var pellet_position: Vector2 = Vector2.ZERO
			if i.has("id"):
				pellet_name = i.id
			if i.has("mass"):
				pellet_scale = Vector2(i.mass / pellet.texture.get_size().x, i.mass / pellet.texture.get_size().y)
			if i.has("x") and i.has("y"):
				pellet_position = Vector2(i.x, i.y)
			pellet.name = pellet_name
			pellet.scale = pellet_scale
			pellet.global_position = pellet_position
			pellet.modulate = PELLETS_POSSIBLE_COLORS[randi()%PELLETS_POSSIBLE_COLORS.size()]
			pellets_holder.add_child(pellet)
			GameHttpNetworkManager.update_pellets_list(pellet_name, pellet)
			#NetworkManager.nakama_update_pellets_in_current_room(i.id, pellet)
	else:
		print("pellets not assigned in game under inGameNetworkManager")

func _on_reset_game_signal() -> void:
	print("reset signal emitted")
	remove_all_old_players()
	remove_all_old_pellets()
