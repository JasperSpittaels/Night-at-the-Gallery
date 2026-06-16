extends Control

@onready var caught_text: Label = $CenterContainer/VBoxContainer/Label

func _ready() -> void:
	caught_text.text = "You were caught by the guard"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _on_return_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Scene.tscn")
