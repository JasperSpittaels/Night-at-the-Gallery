extends CharacterBody3D

@export var SPEED: float = 0.75
@export var JUMP_VELOCITY: float = 0.5
@export var mouse_sensitivity: float = 0.003
@export var gravity_scale: float = 0.2

@onready var interaction_ui: Label = $Interact/Label
@onready var camera: Camera3D = $Head/Camera3D
@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D

var has_key: bool = false
var has_mona_lisa: bool = false

var outside_position: Vector3 = Vector3(1.39, 0.165, -1.39)
var outside_look_position: Vector3 = Vector3(0, 0, -45)

func _enter_tree() -> void:
	var node_id = name.to_int()
	set_multiplayer_authority(node_id)

func _ready() -> void:
	add_to_group("Players")
	camera.current = is_multiplayer_authority()

	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		interaction_ui.visible = false
	else:
		camera.current = false
		interaction_ui.visible = false
		return

	if not multiplayer.is_server():
		var synchronizer = $MultiplayerSynchronizer
		if synchronizer:
			synchronizer.public_visibility = false

		await get_tree().create_timer(0.05).timeout
		global_position = Vector3(1.15, 0.165, -1.15)
		rotation_degrees.y = 135

		if synchronizer:
			synchronizer.public_visibility = true

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if not is_inside_tree():
		return

	interaction()

	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta

	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	for i in get_slide_collision_count():
		if not is_inside_tree():
			return

		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if has_mona_lisa and collider and Input.is_action_just_pressed("escape"):
			teleport_outside(outside_position, outside_look_position)
			break

func interaction() -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()

		if not collider:
			interaction_ui.visible = false
			return

		# Key
		if collider.has_method("interact_key"):
			interaction_ui.text = "Press [E] to grab key"
			interaction_ui.visible = true

			if Input.is_action_just_pressed("interact"):
				collider.interact_key()
				has_key = true

		# Door
		elif collider.has_method("interact_door"):
			if interaction_ui.text != "Door is stuck":
				interaction_ui.text = "Press [E] to open"
				interaction_ui.visible = true

			if Input.is_action_just_pressed("interact"):
				if has_key:
					collider.interact_door()
				else:
					interaction_ui.text = "Door is stuck"
					interaction_ui.visible = true

					await get_tree().create_timer(2.0).timeout

					if raycast.get_collider() == collider:
						interaction_ui.text = "Press [E] to open"

		# Mona Lisa
		elif collider.has_method("interact_mona_lisa"):
			interaction_ui.text = "Press [E] to grab the Mona Lisa"
			interaction_ui.visible = true

			if Input.is_action_just_pressed("interact"):
				collider.interact_mona_lisa($Hand)
				has_mona_lisa = true

		else:
			interaction_ui.visible = false

	else:
		interaction_ui.visible = false

func teleport_outside(_outside_position: Vector3, _outside_look_position: Vector3) -> void:
	velocity = Vector3.ZERO
	global_position = outside_position
	look_at(outside_look_position, Vector3.UP)
