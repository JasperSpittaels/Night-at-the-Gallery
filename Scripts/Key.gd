extends StaticBody3D

@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	visible = true
	collision.disabled = false
	
func interact_key() -> void:
	visible = false
	collision.disabled = true
