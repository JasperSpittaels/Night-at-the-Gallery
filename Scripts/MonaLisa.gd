extends StaticBody3D

@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	collision.disabled = false
	
func interact_mona_lisa(hand: Node3D) -> void:
	collision.disabled = true
	
	get_parent().remove_child(self)
	hand.add_child(self)
