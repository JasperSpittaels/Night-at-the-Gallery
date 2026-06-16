extends CharacterBody3D

@export var animation_speed = 1.25
@export var speed: float = 0.4
@export var max_distance: float = 1.0

@onready var long_raycast: RayCast3D = $Head/LongRayCast3D
@onready var short_raycast: RayCast3D = $Head/ShortRayCast3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var start_position: Vector3
var is_following: bool = false
var duration: float = 3.0

func _ready() -> void:
	start_position = global_position

	if animation_player.has_animation("Patrol"):
		animation_player.speed_scale = animation_speed
		animation_player.play("Patrol")

func _physics_process(_delta: float) -> void:
	var player = get_closest_player()

	if player == null:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var current_distance = global_transform.origin.distance_to(player.global_transform.origin)

	if long_raycast.is_colliding():
		var collider = long_raycast.get_collider()
		if collider == player and current_distance <= max_distance:
			if not is_following:
				is_following = true
				var exact_current_position = global_transform.origin
				animation_player.stop()
				global_transform.origin = exact_current_position

	if short_raycast.is_colliding():
		var collider = short_raycast.get_collider()
		if collider == player:
			if is_following:
				get_tree().change_scene_to_file("res://Scenes/Caught.tscn")
				return

	if is_following and current_distance > max_distance:
		is_following = false

		look_at(start_position, Vector3.UP)
		rotation.y += PI
		rotation.x = 0
		rotation.z = 0

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", start_position, duration)
		tween.tween_callback(_on_reached_start_position)

	if is_following:
		look_at(player.global_transform.origin, Vector3.UP)
		rotation.y += PI
		rotation.x = 0
		rotation.z = 0

		var direction = player.global_transform.origin - global_transform.origin
		direction.y = 0
		direction = direction.normalized()

		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		move_and_slide()

func _on_reached_start_position() -> void:
	if animation_player.has_animation("Patrol"):
		animation_player.play("Patrol")

func get_closest_player() -> CharacterBody3D:
	var players = get_tree().get_nodes_in_group("Players")
	var closest_player: CharacterBody3D = null
	var shortest_distance: float = INF

	for p in players:
		if p is CharacterBody3D:
			var dist = global_position.distance_to(p.global_position)
			if dist < shortest_distance:
				shortest_distance = dist
				closest_player = p

	return closest_player
