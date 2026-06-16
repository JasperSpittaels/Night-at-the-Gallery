extends StaticBody3D

var animation: String = "Door"
var animation_player_path: NodePath = "../../AnimationPlayer"
var animation_player: AnimationPlayer
var is_open: bool = false

func _ready() -> void:
	animation_player = get_node(animation_player_path) as AnimationPlayer
	
func interact_door() -> void:
	if not is_open:
		animation_player.play(animation)
		is_open = true
	else:
		animation_player.play_backwards(animation)
		is_open = false
