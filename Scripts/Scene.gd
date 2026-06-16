extends Node3D

var peer = ENetMultiplayerPeer.new()

@export var player_scene: PackedScene

func _ready() -> void:
	$MainMenu.visible = true
	
func _on_create_group_btn_pressed() -> void:
	if peer != null:
		peer.close()
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(9999, 3)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	add_player(multiplayer.get_unique_id())
	$MainMenu.visible = false

func _on_join_group_btn_pressed() -> void:
	if peer != null:
		peer.close()

	peer = ENetMultiplayerPeer.new()
	peer.create_client("pop-tune.gl.at.ply.gg", 31832)
	multiplayer.multiplayer_peer = peer
	$MainMenu.visible = false

func add_player(id = 1) -> void:
	if not multiplayer.is_server():
		return

	if $Spawn.has_node(str(id)):
		return

	var player = player_scene.instantiate()
	player.name = str(id)
	$Spawn.add_child(player)

	player.global_position = Vector3(1.15, 0.165, -1.15)
	player.rotation_degrees.y = 135

func del_player(id) -> void:
	if not multiplayer.is_server():
		return

	var player_node = $Spawn.get_node_or_null(str(id))
	if player_node:
		player_node.queue_free()

func _on_quit_btn_pressed() -> void:
	if peer != null:
		peer.close()

	get_tree().quit()
